module T10
  module Rooms
    class MachineryRoom < Room
      DOORS = 3

      def initialize
        super
        @has_left = true
        @has_right = false
        @has_ahead = true
      end

      def desc_name
        "machinery"
      end
    end
  end
end
