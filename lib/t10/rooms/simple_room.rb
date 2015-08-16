module T10
  module Rooms
    class SimpleRoom < Room
      DOORS = 1

      NOUNS = {}

      VERBS = {}

      MODIFIERS = {}

      def initialize
        super
        @has_left = false
        @has_right = false
        @has_ahead = false

        @room_items = [
          T10::Items::ShinyItem
        ]
      end

      def words
        if @current_event
          super
        else
          verbs, nouns, modifiers = super
          [VERBS.merge(verbs), NOUNS.merge(nouns), MODIFIERS.merge(modifiers)]
        end
      end

      def desc_name
        @shiny_obtained ? "[] simple room" : "[+] simple room"
      end

      protected

      def item_obtained(item_class)
        if item_class == T10::Items::ShinyItem
          T10::Book.simple_room[:obtained_shiny]
        end
      end

      def enter(nouns, modifiers)
        super
        if @visited
          [] << T10::Book.simple_room[:enter_visited]
        else
          @visited = true
          [] << T10::Book.simple_room[:enter]
        end
      end


    end
  end
end
