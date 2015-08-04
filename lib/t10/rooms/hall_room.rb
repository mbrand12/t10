module T10
  module Rooms
    class HallRoom < Room
      DOORS = 4

      def initialize
        @has_left = true
        @has_right = true
        @has_ahead = true
      end
    end
  end
end
