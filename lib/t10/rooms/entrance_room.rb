module T10
  module Rooms
    # The starting room (area) for the hero.
    #
    # The :look and :touch {VERBS} are the main way of getting new hints and
    # description and should be implemented in all rooms.
    class EntranceRoom < Room

      # The number of available doors, origin door included.
      DOORS = 2

      VERBS =  {
        look:  %i(look study stare),
        touch: %i(touch poke tap),
        open:  %i(open)
      }

      NOUNS = {
        gate:  %i(gate doorway),
        path:  %i(path pathway ground),
        wall:  %i(wall),
        crest: %i(crest)
      }

      def initialize
        super
        @has_ahead = true
        @has_left  = false
        @has_right = false

        @gate_open = false

        @hero = Hero.new
      end

      # @return [String] the text that will show on the command prompt.
      def desc_name
        "][ the gate"
      end

      # See {Room#words}
      def words
        if @current_event
          super
        else
          verbs, nouns, modifiers = super
          nouns = nouns.reject {|k,_| k == :satchel}
          [VERBS.merge(verbs), NOUNS.merge(nouns),MODIFIERS.merge(modifiers)]
        end
      end

      private

      def enter(nouns, modifiers)
        modifiers.pop if modifiers.last.is_a?(Hero) && @visited
        super
        if @visited
          Book.entrance_room[:enter_visited]
        else
          @visited = true
          Book.entrance_room[:enter]
        end
      end

      def exit(nouns, _modifiers)
        if nouns.include?(:gate)
          enter_dungeon
        elsif nouns.include?(:path)
          @hero = nil
          Book.entrance_room[:enter_path]
        else
          Book.entrance_room[:enter_nothing]
        end
      end

      def look(nouns, modifiers)
        if nouns.include?(:gate) || modifiers.include?(:ahead)
          Book.entrance_room[:look_gate] %
            [crest: get_desc_crest_from_relative(:ahead)]
        elsif nouns.include?(:wall) ||
            modifiers.include?(:to_left) || modifiers.include?(:to_right)
          Book.entrance_room[:look_wall]
        elsif nouns.include?(:path) || modifiers.include?(:origin)
          Book.entrance_room[:look_path]
        elsif nouns.include?(:crest)
          Book.entrance_room[:look_crest] %
            [crest: get_desc_crest_from_relative(:ahead)]
        else
          Book.entrance_room[:look_nothing]
        end
      end

      def touch(nouns, modifiers)
        if nouns.include?(:gate)
          if @gate_open
            Book.entrance_room[:touch_open_gate]
          else
            @gate_open = true
            Book.entrance_room[:touch_gate]
          end
        elsif nouns.empty?
         Book.entrance_room[:touch_nothing]
        else
          Book.entrance_room["touch_#{nouns.pop}".to_sym]
        end
      end

      def open(nouns, modifiers)
        if nouns.include?(:gate)
          if @gate_open
            Book.entrance_room[:open_opened_gate]
          else
            @gate_open = true
            Book.entrance_room[:open_gate]
          end
        else
          Book.entrance_room[:open_nothing]
        end
      end

      def enter_dungeon
        desc = []

        crest, _, _, _, next_room = @doors.find{|_, v| v[-2] == :ahead}.flatten
        @doors[crest][0] = true
        nroom_modifiers = [:cracked, crest, @hero]

        desc << Book.entrance_room[:open_gate] unless @gate_open
        desc << Book.entrance_room[:enter_gate] %
          [hero_max_hp_m1: Hero::MAX_HP - 1]
        desc << Book.entrance_room[:obtain_satchel]

        @hero.obtain_satchel

        desc << next_room.interact([:enter],[], nroom_modifiers)

        # @hero.obtain_satchel if next_room.hero_here?
        @hero = nil if next_room.hero_here?
        desc
      end
    end
  end
end
