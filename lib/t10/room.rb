require 't10/save_event'
require 't10/book'

module T10
  class Room
    DOORS = 4

    VERBS = {
      exit: %i(exit leave escape enter),
      enter: %i()
    }

    NOUNS = {
      door:    %i(door passage passageway enterance),
      satchel: %i(satchel inventory stash)

    }

    MODIFIERS = {
      e_dragon:  %i{dragon},
      s_phoenix: %i{phoenix},
      w_tiger:   %i{tiger},
      n_turtle:  %i{turtle},
      to_left:   %i{left leftmost},
      to_right:  %i{right rightmost},
      ahead:     %i{ahead straight},
      origin:    %i{back behind}
    }

    @rooms = []
    class << self
      attr_reader :rooms
    end

    def self.inherited(room_implementations)
      @rooms << room_implementations
    end

    attr_writer :hero

    def initialize()
      @visited = false

      @has_left  = false
      @has_right = false
      @has_ahead = false

      @doors = {
        e_dragon:  [false, nil, nil],
        s_phoenix: [false, nil, nil],
        w_tiger:   [false, nil, nil],
        n_turtle:  [false, nil, nil]
      }

      @hero = nil
      @current_event = nil

      @items = []
      @shiny_obtained = false
    end

    def connect_to(room = nil )
      return add_origin_door unless room
      @doors[add_door(room)][2].add_origin_door(self)
    end

    def words
      if @current_event
        @current_event.words
      elsif @hero && @hero.satchel
        verbs, nouns, mods = @hero.satchel.words
        nouns = nouns.merge(get_items_hash)
        [VERBS.merge(verbs), NOUNS.merge(nouns), MODIFIERS.merge(mods)]
      else
        [VERBS, NOUNS.merge(get_items_hash), MODIFIERS]
      end
    end

    def interact(verbs, nouns, modifiers)

      @current_event = nil if modifiers.include?(:game_load)


      if @current_event
        desc = @current_event.interact(verbs, nouns, modifiers)

        if @current_event.complete
          e_verb, e_nouns, e_modifiers = @current_event.get_back_data
          send(e_verb, e_nouns, e_modifiers)
        else
          desc
        end
      elsif nouns.include?(:satchel)
        nouns -= [:satchel]
        modifiers = @items.map {|item| item.item_name }
        desc = @hero.satchel.interact(verbs, nouns, modifiers)
        if desc.last.is_a?(Symbol)
          symbol = desc.last
          remove_item(symbol)
          @shiny_obtained = true if symbol == T10::Items::ShinyItem.item_name
          desc.pop
        end
        desc
      elsif verbs.empty? || !VERBS.include?(verbs[0]) ||
            modifiers.include?(:no_words)
        Book.room[:no_words]
      else
        send(verbs[0], nouns, modifiers)
      end
    end

    def hero_here?
      true if @hero
    end

    def desc_name; fail NotImplementedError; end

    def desc_short; fail NotImplementedError; end

    protected

    def add_door(room)

      if @doors.find {|_, v| v[2].class == room.class}
        fail StandardError, "Duplicate rooms now allowed!"
      end

      left_crest  = get_crest_from_relative(:to_left)
      right_crest = get_crest_from_relative(:to_right)
      ahead_crest = get_crest_from_relative(:ahead)

      case
      when @has_left && @doors[left_crest][2].nil?
        @doors[left_crest][2] = room
        left_crest
      when @has_right && @doors[right_crest][2].nil?
        @doors[right_crest][2] = room
        right_crest
      when @has_ahead && @doors[ahead_crest][2].nil?
        @doors[ahead_crest][2] = room
        ahead_crest
      else
        fail StandardError,
          "All doors for room #{self.class} occupied." \
          " #{room.class} not added."
      end
    end

    def add_origin_door(origin_room = nil)
      crest = nil
      if origin_room
        crest = origin_room.get_crest_leading_to(self)

        unless crest
          fail StandardError,
            "#{origin_room} should lead to this (#{self.class} room) before " \
            "#{self.class} can lead to #{origin_room}"
        end
      else
        crest = [:e_dragon, :s_phoenix, :w_tiger, :n_turtle].sample
      end

      case crest
      when :e_dragon
        @doors = {
          e_dragon:  [false, :ahead, nil],
          s_phoenix: [false, :to_right, nil],
          w_tiger:   [false, :origin, origin_room],
          n_turtle:  [false, :to_left, nil]
        }
      when :s_phoenix
        @doors = {
          e_dragon:  [false, :to_left, nil],
          s_phoenix: [false, :ahead, nil],
          w_tiger:   [false, :to_right, nil],
          n_turtle:  [false, :origin, origin_room]
        }
      when :w_tiger
        @doors = {
          e_dragon:  [false, :origin, origin_room],
          s_phoenix: [false, :to_left, nil],
          w_tiger:   [false, :ahead, nil],
          n_turtle:  [false, :to_right, nil]
        }
      when :n_turtle
        @doors = {
          e_dragon:  [false, :to_right, nil],
          s_phoenix: [false, :origin, origin_room],
          w_tiger:   [false, :to_left, nil],
          n_turtle:  [false, :ahead, nil]
        }
      end
      self
    end

    def get_crest_leading_to(room)
      door = @doors.find {|_, v| v[2].class == room.class}
      crest = door[0] if door
    end

    def exit(nouns, modifiers)
      desc = []
      door = get_door_data(modifiers)

      unless door
        return desc << Book.room[:which_door]
      end
      crest, orb_cracked, _, next_room = door

      unless next_room
        return desc <<  Book.room[:sealed_door]
      end

      unless @current_event
        @current_event = SaveEvent.new(:exit, nouns, modifiers)
        return @current_event.intro
      end
      nroom_modifiers = []
      desc.concat orb_event(orb_cracked)
      desc.insert(-2, modifiers.pop) if modifiers.last.is_a?(String)
      if desc.pop
        @doors[crest][0] = true
        nroom_modifiers << :cracked << crest
      end
      nroom_modifiers << @hero
      @current_event = nil
      desc.concat next_room.interact([:enter],[], nroom_modifiers)
      @hero = nil if next_room.hero_here?
      desc
    end

    def enter(nouns, modifiers)
      @hero = modifiers.pop if modifiers.last.is_a?(Hero)
      if modifiers.include?(:cracked)
        @doors[get_crest_from_absolute(modifiers.pop)][0] = true
      end
      desc = []
    end

    private

    def remove_item(item_name)
      @items.delete_if {|item| item.item_name == item_name}
    end

    def get_items_hash
      return {} if @items.empty?

      result_hash = {}
      @items.each {|item| result_hash.update(item.item_words)}
      result_hash
    end


    def orb_event(orb_cracked)
      desc = []
      if orb_cracked
        desc << Book.room[:orb_cracked]<< false
      elsif !orb_cracked && !@hero.at_full_health? && @hero.chance_heal(1)
        desc << Book.room[:orb_heal] % [hit_points: @hero.hit_points] << true
      else
        desc << Book.room[:orb_no_heal] << false
      end
    end

    def get_crest_from_relative(orientation)
      door = @doors.find { |_, v| v[1] == orientation }
      door[0] if door
    end

    def get_crest_from_absolute(other_room_crest)
      door = @doors.find { |k, v| k == orient(other_room_crest) }
      door[0] if door
    end

    def get_door_data(modifiers)
      door = @doors.find do
        |k, v| modifiers.include?(k) || modifiers.include?(v[1])
      end
      return nil unless door
      door.flatten
    end

    def orient(room_crest)
      case room_crest
      when :e_dragon
        :w_tiger
      when :s_phoenix
        :n_turtle
      when :w_tiger
        :e_dragon
      when :n_turtle
        :s_phoenix
      end
    end
  end
  require 't10/rooms/entrance_room'
  require 't10/rooms/end_room'
  require 't10/rooms/armor_room'
  require 't10/rooms/boss_room'
  require 't10/rooms/empty_room'
  require 't10/rooms/hall_room'
  require 't10/rooms/hidden_door_room'
  require 't10/rooms/jungle_room'
  require 't10/rooms/machinery_room'
  require 't10/rooms/maze_room'
  require 't10/rooms/simple_room'
  require 't10/rooms/trap_room'
end

