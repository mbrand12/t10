require "t10/rooms/under_construction"

module T10
  module Rooms
    class MazeRoom < Room
      include Rooms::UnderConstruction

      DOORS = 2

      def initialize
        super
        @has_left = false
        @has_right = true
        @has_ahead = false
      end

      def desc_name
        "maze"
      end
    end
  end
end
