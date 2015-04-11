module T10
  module Items
    class AmuletItem < Item

      def self.item_name
        :amulet
      end

      def self.item_words
        {amulet: %i(amulet)}
      end

      def initialize
        @quantity = 1
        @quality = 0
        @max_quality = 1
        @max_quantity = 10
      end


      def desc_name
        Book.amulet_item[:desc_name]
      end

      def desc_short
        if @quality == 0
          Book.amulet_item[:desc_short_q0]
        elsif @quality < @max_quality
          Book.amulet_item[:desc_short] % [item_quality: @quality]
        else
          Book.amulet_item[:desc_short_complete]
        end
      end

      def desc_long
        @checked = true
        Book.amulet_item[:desc_long]
      end
    end
  end
end
