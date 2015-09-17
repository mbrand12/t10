module T10
  module Rooms
    class EndRoom < Room
      DOORS = 1

      VERBS = {
        look: %i(look glare stare),
        touch: %i(touch poke tap)
      }

      NOUNS = {
        wall: %i(wall),
        hole: %i(hole opening crevice)
      }

      MODIFIERS = {}

      def initialize
        super
        @has_left = false
        @has_right = false
        @has_ahead = false

        @key_item_slots = {
          Items::AmuletItem.item_name => %i(hole wall)
        }
      end

      def words
        if @current_event
          super
        else
          verbs, nouns, mods = super
          [VERBS.merge(verbs), NOUNS.merge(nouns), MODIFIERS.merge(mods)]
        end
      end

      def desc_name
        "beyond the dungeon"
      end

      def item_used(item_symbol)
        if item_symbol == Items::AmuletItem.item_name
          @hero = nil
          Book.end_room[:used_amulet]
        end
      end

      def enter(nouns, modifiers)
        super
        if @visited
          Book.end_room[:enter_visited]
        else
          @visited = true
          Book.end_room[:enter]
        end
      end

      def look(nouns, modifiers)
        if nouns.empty?
          crests = [:e_dragon, :s_phoenix, :n_turtle, :w_tiger]
          if modifiers.empty? || crests.include?(modifiers.first)
            Book.end_room[:look_nothing]
          else
            Book.end_room["look_#{modifiers.first}".to_sym]
          end
        end
      end

      def touch(nouns, modifiers)
        if nouns.empty?
          Book.end_room[:touch_nothing]
        else
          Book.end_room["touch_#{nouns.first}".to_sym]
        end
      end
    end
  end
end
