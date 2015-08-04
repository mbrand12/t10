module T10
  module Rooms
    class SimpleRoom < Room
      DOORS = 1

      def initialize
        @has_left = false
        @has_right = false
        @has_ahead = false
      end
    end
  end
end
