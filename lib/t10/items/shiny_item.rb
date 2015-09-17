module T10
  module Items
    class ShinyItem < Item
      def self.item_name
        :shiny
      end

      def self.item_words
        {shiny: %i(shiny piece)}
      end

      def initialize
        @quantity = 1
        @quality  = 0
        @max_quality = 0
        @max_quantity = 10
      end

      def desc_put
        Book.shiny_item[:desc_put].chomp
      end

      def desc_name
        if @quantity == 1
          Book.shiny_item[:desc_name].chomp
        else
          Book.shiny_item[:desc_name_qn].chomp % [item_quantity: @quantity]
        end
      end

      def desc_short
        if @quantity == 1
          Book.shiny_item[:desc_short]
        else
          Book.shiny_item[:desc_short_qn] % [item_quantity: @quantity]
        end
      end

      def desc_long
        if @quantity == 1
          Book.shiny_item[:desc_long]
        else
          Book.shiny_item[:desc_long] << " " <<
            Book.shiny_item[:desc_long_qn] % [item_quantity: @quantity]
        end
      end
    end
  end
end
