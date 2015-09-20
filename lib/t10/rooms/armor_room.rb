module T10
  module Rooms
    # The armor room is first room where a major event is implemented. Read
    # more about it at #{Events::ArmorEvent} and DEVCORE.md.
    class ArmorRoom < Room
      DOORS = 1

      VERBS = {
        look: %i(look glare stare),
        touch: %i(touch poke tap)
      }

      VERBS_2 = {
        go: %i(go climb run approach)
      }

      NOUNS = {
        crest: %i(crest),
        armor: %i(armor armour armored armoured figure hand),
        pedestal: %i(pedestal),
        wall: %i(wall),
        pillar: %i(pillar pillars),
        stone: %i(stone statue)
      }

      NOUNS_2 = {
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

        @room_items = [Items::ShinyItem]

        @battle_done = false
      end

      # See {Room#words}
      def words
        if @current_event
          super
        else
          verbs, nouns, mods = super
          if @shiny_obtained
            [VERBS_2.merge(verbs), NOUNS_2.merge(nouns), MODIFIERS.merge(mods)]
          else
            [VERBS.merge(verbs), NOUNS.merge(nouns), MODIFIERS.merge(mods)]
          end
        end
      end

      # See {Room#desc_name}
      def desc_name
        @shiny_obtained ? "[] armor room" : "[+] armor room"
      end

      protected

      def item_obtained(item_class)
        if item_class == Items::ShinyItem
          @shiny_obtained = true
          Book.armor_room[:obtained_shiny]
        end
      end

      private

      def enter(nouns, modifiers)
        modifiers.pop if modifiers.last.is_a?(Hero) && @battle_done
        super
        if @battle_done
          desc = [Book.armor_room[:enter_battle_done]]
          if modifiers.include?(:game_load)
            desc << send(:exit, [], [:origin, :no_save])
          end
          des
        elsif @visited
          Book.armor_room[:enter_visited]
        else
          @visited = true
          Book.armor_room[:enter]
        end
      end

      def exit(nouns, modifiers)
        if @shiny_obtained && !modifiers.include?(:battle_over)
          @hero = nil
          Book.armor_room[:go_door]
        else
          super
        end
      end

      def look(nouns, modifiers)
        if nouns.empty?
          crests = [:e_dragon, :s_phoenix, :n_turtle, :w_tiger]
          if modifiers.empty? || crests.include?(modifiers.first)
            Book.armor_room[:look_nothing]
          else
            Book.armor_room["look_#{modifiers.first}".to_sym]
          end
        elsif nouns.include?(:crest)
          Book.armor_room[:look_crest] %
                [crest: get_desc_crest_from_relative(:origin)]
        elsif nouns.include?(:door) || modifiers.include?(:origin)
          Book.armor_room[:look_door] %
                [crest: get_desc_crest_from_relative(:origin)]
        else
          Book.armor_room["look_#{nouns.first}".to_sym]
        end
      end

      def touch(nouns, modifiers)
        if nouns.empty?
          Book.armor_room[:touch_nothing]
        else
          Book.armor_room["touch_#{nouns.first}".to_sym]
        end
      end

      def go(nouns, modifiers)
        if nouns.empty?
          Book.armor_room[:go_nothing]
        elsif nouns.include?(:armor)
          @current_event = Events::ArmorEvent.new(:battle_over, [], [])
          @current_event.intro
        else
          @hero = nil
          Book.armor_room["go_#{nouns.first}".to_sym]
        end
      end


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
          desc << exit(nil, [:origin, :battle_over])
        end
        desc
      end
    end
  end
end
