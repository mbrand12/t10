module T10
  module Rooms
    class MazeRoom < Room
      DOORS = 2

      def initialize
        super
        @has_left = true
        @has_right = false
        @has_ahead = false
      end

      def desc_name
        "maze"
      end
    end
  end
end
