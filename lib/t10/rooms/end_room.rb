module T10
  module Rooms
    class EndRoom < Room
      DOORS = 1

      VERBS = {}

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
          T10::Items::AmuletItem.item_name => %i(hole wall)
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
        if item_symbol == T10::Items::AmuletItem.item_name
          @hero = nil
          T10::Book.end_room[:used_amulet]
        end
      end

      def enter(nouns, modifiers)
        super
        if @visited
          [] << T10::Book.end_room[:enter_visited]
        else
          @visited = true
          [] << T10::Book.end_room[:enter]
        end

      end
    end
  end
end
