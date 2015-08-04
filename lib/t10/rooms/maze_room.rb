module T10
  module Rooms
    class MazeRoom < Room
      DOORS = 2

      def initialize
        @has_left = true
        @has_right = false
        @has_ahead = false
      end
    end
  end
end
