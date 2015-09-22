module T10
  module Items
    # Amulet item is a token usable item in the game, However it can only be
    # used when it is completed by combining it with all the {Items::ShinyItem}
    # pieces.  For the details on the methods and such see {Item}.
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
        @max_quality = 10
        @max_quantity = 1
      end

      def desc_name
        Book.amulet_item[:desc_name].chomp
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
        Book.amulet_item[:desc_long]
      end

      def desc_combined(q_or_q)
        if q_or_q == 1
          Book.amulet_item[:desc_combined]
        else
          Book.amulet_item[:desc_combined_qn] % [q_or_q: q_or_q]
        end
      end
    end
  end
end
