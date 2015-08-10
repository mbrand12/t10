module T10
  module Rooms
    class EndRoom < Room
      DOORS = 1

      def initialize
        super
        @has_left = false
        @has_right = false
        @has_ahead = false
      end
      def desc_name
        "beyond the dungeon"
      end
    end
  end
end
