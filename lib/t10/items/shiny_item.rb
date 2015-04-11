module T10
  module Items
    class ShinyItem < Item
      def self.item_name
        :shiny
      end

      def self.item_words
        {shiny: %i(shiny)}
      end

      def initialize(quantity)
        @quantity = 1
        @quality  = 0

        @checked = false
      end

      def desc_name
        Book.shiny_item[:desc_name]
      end

      def desc_short
        if @quantity == 1
          Book.shiny_item[:desc_short]
        else
          Book.shiny_item[:desc_short_qn] % [item_quantity: @quantity]
        end
      end

      def desc_long
        @checked = true

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
