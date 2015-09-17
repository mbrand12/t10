module T10
  module Rooms
    class ArmorRoom < Room
      DOORS = 1

      VERBS = {
        look: %i(look glare stare),
        touch: %i(touch poke tap)
      }

      VERBS_2 = {
        go: %i(go climb run)
      }

      NOUNS = {
        armor: %i(armor armour armored armoured figure hand),
        pedestal: %i(pedestal),
        wall: %i(wall),
        pillar: %i(pillar pillars),
        stone: %i(stone statue)
      }

      MODIFIERS = {}

      def initialize
        super
        @has_left = false
        @has_right = false
        @has_ahead = false

        @room_items = [T10::Items::ShinyItem]

        @battle_done = false
      end

      def words
        if @current_event
          super
        else
          verbs, nouns, mods = super
          if @shiny_obtained
            verbs = verbs.merge(VERBS_2)
          end
          [VERBS.merge(verbs), NOUNS.merge(nouns), MODIFIERS.merge(mods)]
        end
      end

      def desc_name
        @shiny_obtained ? "[] armor room" : "[+] armor room"
      end

      protected

      def item_obtained(item_class)
        if item_class == T10::Items::ShinyItem
          @shiny_obtained = true
          T10::Book.armor_room[:obtained_shiny]
        end
      end

      def enter(nouns, modifiers)
        modifiers.pop if modifiers.last.is_a?(Hero) && @battle_done
        super
        if @battle_done
          [] << T10::Book.armor_room[:enter_battle_done]
        elsif @visited
          [] << T10::Book.armor_room[:enter_visited]
        else
          @visited = true
          [] << T10::Book.armor_room[:enter]
        end
      end

      def look(nouns, modifiers)
        if nouns.empty?
          [] << T10::Book.armor_room[:look_nothing]
        else
          [] << T10::Book.armor_room["look_#{nouns.first}".to_sym]
        end
      end

      def touch(nouns, modifiers)
        if nouns.empty?
          [] << T10::Book.armor_room[:touch_nothing]
        else
          [] << T10::Book.armor_room["touch_#{nouns.first}".to_sym]
        end
      end

      def go(nouns, modifiers)
        if nouns.empty?
          [] << T10::Book.armor_room[:go_nothing]
        elsif nouns.include?(:armor)
          @current_event = T10::Events::ArmorEvent.new(:battle_over, nil, nil)
          @current_event.intro
        else
          @hero = nil
          [] << T10::Book.armor_room["go_#{nouns.first}".to_sym]
        end
      end

      private

      def battle_over(nouns, modifiers)
        desc = []
        if modifiers.include?(:battle_lost)
          @hero = nil
          desc << @current_event.outro
          @current_event = nil
        elsif modifiers.include?(:battle_won)
          @battle_done = true
          desc << @current_event.outro
          @current_event = nil
          desc << exit(nil, [:origin])
        end
        desc
      end
    end
  end
end
