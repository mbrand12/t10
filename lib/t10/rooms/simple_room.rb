module T10

  module Rooms
    # Simple room is first room made to test how the items are obtained as well
    # as the satchel functionality. The goal here is to get the shiny piece by
    # following the hints given by the descriptions.
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

      # See {Rooms::EntranceRoom#words}
      def words
        if @current_event
          super
        else
          verbs, nouns, modifiers = super
          [VERBS.merge(verbs), NOUNS.merge(nouns), MODIFIERS.merge(modifiers)]
        end
      end

      # See {Room#desc_name}
      def desc_name
        @shiny_obtained ? "[] simple room" : "[+] simple room"
      end

      protected

      # See {Room#item_obtained} 
      def item_obtained(item_class)
        if item_class == Items::ShinyItem
          Book.simple_room[:obtained_shiny]
        end
      end

      private

      def enter(nouns, modifiers)
        super
        if @visited
          Book.simple_room[:enter_visited]
        else
          @visited = true
          Book.simple_room[:enter]
        end
      end

      def look(nouns, modifiers)
        if @meal_appeared
          Book.simple_room[:look_meal_appeared]
        elsif @meal_eaten && nouns.include?(:desk)
          @shiny_obtained = true
          @room_items << T10::Items::ShinyItem
          [Book.simple_room[:look_desk_after],
                interact([:put], [:satchel, :shiny], [])]
        elsif nouns.empty?
          crests = [:e_dragon, :s_phoenix, :n_turtle, :w_tiger]
          if modifiers.empty? || crests.include?(modifiers.first)
            Book.simple_room[:look_nothing]
          else
            Book.simple_room["look_#{modifiers.first}".to_sym]
          end
        elsif nouns.include?(:crest)
          Book.simple_room[:look_crest] %
                [crest: get_desc_crest_from_relative(:origin)]
        elsif nouns.include?(:meal) && @meal_eaten
          Book.simple_room[:look_meal_eaten]
        else
          Book.simple_room["look_#{nouns.first}".to_sym]
        end
      end

      def touch(nouns, modifiers)
        if @meal_appeared
          Book.simple_room[:touch_meal_appeared]
        elsif nouns.empty?
          @touch_counter += 1
          if @touch_counter == 10
            @touch_counter = 0
            Book.simple_room[:touch_nothing_10th]
          else
            Book.simple_room[:touch_nothing]
          end
        else
          T10::Book.simple_room["touch_#{nouns.first}".to_sym]
        end
      end

      def sit(nouns, modifiers)
        if @meal_appeared
          Book.simple_room[:sit_meal_appeared]
        elsif nouns.empty?
          Book.simple_room[:sit_nothing]
        elsif @meal_eaten && ( nouns.include?(:chair) || nouns.include?(:bed) )
          Book.simple_room[:sit_overstayed]
        elsif nouns.include?(:chair)
          @meal_appeared = true
          Book.simple_room[:sit_chair]
        elsif nouns.include?(:bed)
          Book.simple_room[:sit_bed]
        elsif nouns.include?(:desk)
          Book.simple_room[:sit_desk]
        else
          Book.simple_room[:sit_no]
        end
      end

      def eat(nouns, modifiers)
        if @meal_appeared && nouns.include?(:meal)
          @meal_eaten = true
          @meal_appeared = false
          Book.simple_room[:eat_meal_appeared]
        elsif nouns.empty?
          Book.simple_room[:eat_nothing]
        elsif nouns.include?(:meal)
          Book.simple_room[:eat_meal]
        else
          Book.simple_room[:eat_no]
        end
      end

      def extinguish(nouns, modifiers)
        if nouns.empty?
          Book.simple_room[:extinguish_nothing]
        elsif @meal_eaten && nouns.include?(:candle)
          @hero = nil
          Book.simple_room[:extinguish_candle_end]
        elsif nouns.include?(:candle)
          Book.simple_room[:extinguish_candle]
        else
          Book.simple_room[:extinguish_no]
        end
      end
    end
  end
end
