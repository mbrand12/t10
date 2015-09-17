module T10
  module Rooms
    class SimpleRoom < Room
      DOORS = 1

      NOUNS = {
        crest: %i(crest),
        wall: %i(wall),
        brick: %i(brick),
        ceiling: %i(ceiling),
        bed: %i(bed),
        chair: %i(chair),
        desk: %i(desk table),
        papers: %i(papers stack),
        inkwell: %i(inkwell ink),
        candle: %i(candle),
        candleholder: %i(candleholder),
        meal: %i(meal food sustinence)
      }

      VERBS = {
        look: %i(look gaze study stare),
        touch: %i(touch poke tap),
        sit: %i(sit),
        eat: %i(eat devour dine),
        rest: %i(rest lie lay),
        extinguish: %i(blow extinguish)
      }

      MODIFIERS = {}

      def initialize
        super
        @has_left = false
        @has_right = false
        @has_ahead = false

        @room_items = []

        @touch_counter = 0
        @meal_appeared = false
        @meal_eaten = false
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

      def look(nouns, modifiers)
        if @meal_appeared
          [] << T10::Book.simple_room[:look_meal_appeared]
        elsif @meal_eaten && nouns.include?(:desk)
          @shiny_obtained = true
          @room_items << T10::Items::ShinyItem
          [] << T10::Book.simple_room[:look_desk_after] <<
                interact([:put], [:satchel, :shiny], [])
        elsif nouns.empty?
          [] << T10::Book.simple_room[:look_nothing]
        elsif nouns.include?(:crest)
          [] << T10::Book.simple_room[:look_crest] %
                [crest: get_desc_crest_from_relative(:origin)]
        elsif nouns.include?(:meal) && @meal_eaten
          [] << T10::Book.simple_room[:look_meal_eaten]
        else
          [] << T10::Book.simple_room["look_#{nouns.first}".to_sym]
        end
      end

      def touch(nouns, modifiers)
        if @meal_appeared
          [] << Book.simple_room[:touch_meal_appeared]
        elsif nouns.empty?
          @touch_counter += 1
          if @touch_counter == 10
            @touch_counter = 0
            [] << T10::Book.simple_room[:touch_nothing_10th]
          else
            [] << T10::Book.simple_room[:touch_nothing]
          end
        else
          [] << T10::Book.simple_room["touch_#{nouns.first}".to_sym]
        end
      end

      def sit(nouns, modifiers)
        if @meal_appeared
          [] << Book.simple_room[:sit_meal_appeared]
        elsif nouns.empty?
          [] << T10::Book.simple_room[:sit_nothing]
        elsif @meal_eaten && ( nouns.include?(:chair) || nouns.include?(:bed) )
          [] << T10::Book.simple_room[:sit_overstayed]
        elsif nouns.include?(:chair)
          @meal_appeared = true
          [] << T10::Book.simple_room[:sit_chair]
        elsif nouns.include?(:bed)
          [] << T10::Book.simple_room[:sit_bed]
        elsif nouns.include?(:desk)
          [] << T10::Book.simple_room[:sit_desk]
        else
          [] << T10::Book.simple_room[:sit_no]
        end
      end

      def eat(nouns, modifiers)
        if @meal_appeared && nouns.include?(:meal)
          @meal_eaten = true
          @meal_appeared = false
          [] << T10::Book.simple_room[:eat_meal_appeared]
        elsif nouns.empty?
          [] << T10::Book.simple_room[:eat_nothing]
        elsif nouns.include?(:meal)
          [] << T10::Book.simple_room[:eat_meal]
        else
          [] << T10::Book.simple_room[:eat_no]
        end
      end

      def extinguish(nouns, modifiers)
        if nouns.empty?
          [] << T10::Book.simple_room[:extinguish_nothing]
        elsif @meal_eaten && nouns.include?(:candle)
          @hero = nil
          [] << T10::Book.simple_room[:extinguish_candle_end]
        elsif nouns.include?(:candle)
          [] << T10::Book.simple_room[:extinguish_candle]
        else
          [] << T10::Book.simple_room[:extinguish_no]
        end
      end
    end
  end
end
