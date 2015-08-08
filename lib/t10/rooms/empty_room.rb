module T10
  module Rooms
    class EmptyRoom < Room
      DOORS = 1

      def initialize()
        @has_left = false
        @has_right = false
        @has_ahead = false
      end

      def desc_name
        "empty room"
      end
    end
  end
end
