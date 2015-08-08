module T10
  module Rooms
    class JungleRoom < Room
      DOORS = 2

      def initialize
        @has_left = false
        @has_right = true
        @has_ahead = false
      end

      def desc_name
        "jungle"
      end
    end
  end
end
