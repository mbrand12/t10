module T10
  module Rooms
    class MachineryRoom < Room
      DOORS = 3

      def initialize
        @has_left = true
        @has_right = false
        @has_ahead = true
      end
    end
  end
end
