require "t10/rooms/under_construction"

module T10
  module Rooms
    class HallRoom < Room
     include Rooms::UnderConstruction

      DOORS = 4

      def initialize
        super
        @has_left = true
        @has_right = true
        @has_ahead = true
      end

      def desc_name
        "great hall"
      end
    end
  end
end
