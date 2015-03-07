module T10
  class Room
    DOORS = 4

    VERBS = {
      exit: %i(exit leave escape enter)
    }

    NOUNS = {
      door: %i(door passage passageway enterance)
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
    end

    def connect_to(room = nil )
      return add_origin_door unless room
      @doors[add_door(room)][2].add_origin_door(self)
    end

    def words
      [VERBS, NOUNS, MODIFIERS]
    end

    def interact(verbs, nouns, modifiers)
      send(verbs.first, nouns, modifiers)
    end

    def hero_here?
      true if @hero
    end

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
        return desc << "I want leave this room, but trough which door " \
                       "should I leave."
      end
      crest, orb_cracked, _, next_room = door

      unless next_room
        return desc <<  "This door is sealed. I'll need to find another door."
      end

      nroom_modifiers = []
      desc.concat orb_event(orb_cracked)
      if desc.pop
        @doors[crest][0] = true
        nroom_modifiers << :cracked << crest
      end
      nroom_modifiers << @hero
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

    def orb_event(orb_cracked)
      desc = []
      if orb_cracked
        desc << "As I go trough the hallway, out of some ancient habit, I " \
                "touch the round stone, now cracked, hoping that even in" \
                "that state it might provide me with some blessing." \
                "It provides me with none." << false
      elsif !orb_cracked && !@hero.at_full_health? && @hero.chance_heal(1)
        desc << "As I go trough the hallway, out of habit, I touch the round " \
                "stone, which emits a gentle glow, and my hopes of it " \
                "restoring me come true. Feeling that I can take " \
                "#{@hero.at_full_health? ? "three" : "two"} more hits " \
                " before I perish, I proceed. "\
                "However, the orb suddenly cracks and the hallway becomes a " \
                "darker place urging me to find whatever comfort I can in the "\
                "room before me." << true
      else
        desc << "As I pass trough the hallway the faint light from the round "\
                "orb grants me respite. I touch the orb and note how warm it "\
                "is and turn my attention over to the next room, leaving the "\
                "glowing orb as it casts my shadow upon the door." << false
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
end

