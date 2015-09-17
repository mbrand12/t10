require 't10/room_connecting_tools'

module T10
  class Room
    include T10::RoomConnectingTools

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
      e_dragon:  %i(dragon),
      s_phoenix: %i(phoenix),
      w_tiger:   %i(tiger),
      n_turtle:  %i(turtle),
      to_left:   %i(left leftmost),
      to_right:  %i(right rightmost),
      ahead:     %i(ahead straight forward),
      origin:    %i(back behind)
    }

    @rooms = []
    class << self
      attr_reader :rooms
    end

    def self.inherited(room_implementations)
      @rooms << room_implementations
    end

    def initialize
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

      @room_items = []
      @key_item_slots = []
      @shiny_obtained = false
    end

    def desc_name; fail NotImplementedError; end

    def hero_here?
      true if @hero
    end

    def words
      if @current_event
        @current_event.words
      elsif @hero && @hero.satchel
        verbs, nouns, mods = @hero.satchel.words
        nouns = nouns.merge(get_room_items_words)
        [VERBS.merge(verbs), NOUNS.merge(nouns), MODIFIERS.merge(mods)]
      else
        [VERBS, NOUNS.merge(get_room_items_words), MODIFIERS]
      end
    end

    def interact(verbs, nouns, modifiers)
      @current_event = nil if modifiers.include?(:game_load)

      if @current_event
        event_interact(verbs, nouns, modifiers)
      elsif nouns.include?(:satchel)
        satchel_interact(verbs, nouns, modifiers)
      elsif verbs.empty? ||
            [:inspect, :put, :use, :combine].include?(verbs[0]) ||
            modifiers.include?(:no_words)
        Book.room[:no_words]
      else
        send(verbs[0], nouns, modifiers)
      end
    end

    protected

    def item_used(item_class); fail NotImplementedError; end
    def item_obtained(item_class); fail NotImplementedError; end

    def enter(nouns, modifiers)
      @hero = modifiers.pop if modifiers.last.is_a?(Hero)
      if modifiers.include?(:cracked)
        @doors[get_crest_from_absolute(modifiers.pop)][0] = true
      end
      desc = []
    end

    def exit(nouns, modifiers)
      desc = []
      door = get_door_data(modifiers)

      unless door
        return Book.room[:which_door]
      end
      crest, orb_cracked, _, next_room = door

      unless next_room
        return Book.room[:sealed_door]
      end

      if @current_event == nil && !modifiers.include?(:no_save)
        @current_event = Events::SaveEvent.new(:exit, nouns, modifiers)
        return @current_event.intro
      end
      nroom_modifiers = []

      @current_event = nil if @current_event && @current_event.complete?

      desc.concat orb_chance(orb_cracked)
      if desc.pop
        @doors[crest][0] = true
        nroom_modifiers << :cracked << crest
      end
      nroom_modifiers << @hero
      @current_event = nil
      desc << next_room.interact([:enter], [], nroom_modifiers)
      @hero = nil if next_room.hero_here?
      desc
    end

    def get_desc_crest_from_relative(orientation)
      door = @doors.find { |_, v| v[1] == orientation }
      door[0].slice(2,door[0].length-2) if door
    end

    private

    def get_room_items_words
      return {} if @room_items.empty?

      result_hash = {}
      @room_items.each { |item| result_hash.update(item.item_words) }
      result_hash
    end

    def event_interact(verbs, nouns, modifiers)

      desc = [@current_event.interact(verbs, nouns, modifiers)]

      if @current_event.complete
        e_verb, e_nouns, e_modifiers = @current_event.get_back_data
        return desc << send(e_verb, e_nouns, e_modifiers)
      end
      desc
    end

    def satchel_interact(verbs, nouns, modifiers)
      nouns -= [:satchel]

      if verbs.include?(:put)
        modifiers = @room_items.map(&:item_name)
      elsif verbs.include?(:use)
        modifiers = key_item_fits(nouns)
      end

      desc = @hero.satchel.interact(verbs, nouns, modifiers)

      if desc.is_a?(Array) && desc.last.is_a?(Symbol)
        symbol = desc.pop

        if removed_item_class = remove_item(symbol)
          desc << item_obtained(removed_item_class)
        elsif key_item_class = remove_key_item_slot(symbol)
          desc << item_used(key_item_class)
        end
        @shiny_obtained = true if symbol == Items::ShinyItem.item_name
      end
      desc
    end

    def key_item_fits(nouns)
      key_item_words = @key_item_slots.find { |k, _| nouns.include?(k) }
      return [] unless key_item_words

      if nouns.any? { |noun| key_item_words[1].include?(noun) }
        [key_item_words[0]]
      else
        []
      end
    end

    def remove_item(item_name)
      deleted = []
      @room_items.delete_if do |item|
        deleted << item if item.item_name == item_name
      end
      deleted.first
    end

    def remove_key_item_slot(item_name)
      deleted = []
      @key_item_slots.delete_if do |k, _|
        deleted << k if k == item_name
      end
      deleted.first
    end

    def get_crest_from_absolute(other_room_crest)
      door = @doors.find { |k, _| k == orient(other_room_crest) }
      door[0] if door
    end

    def get_door_data(modifiers)
      door = @doors.find do |k, v|
        modifiers.include?(k) || modifiers.include?(v[1])
      end
      return nil unless door
      door.flatten
    end

    def orb_chance(orb_cracked)
      if orb_cracked
        [Book.room[:orb_cracked], false]
      elsif !orb_cracked && !@hero.at_full_health? && @hero.chance_heal(1)
        orb_text = Book.room[:orb_heal] % [hit_points: @hero.hit_points]
        [orb_text, true]
      else
        [Book.room[:orb_no_heal], false]
      end
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
