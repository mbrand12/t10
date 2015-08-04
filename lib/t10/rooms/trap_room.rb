module T10
  module Rooms
    class TrapRoom < Room
      DOORS = 2

      def initialize
        @has_left = false
        @has_right = false
        @has_ahead = true
      end
    end
  end
end
