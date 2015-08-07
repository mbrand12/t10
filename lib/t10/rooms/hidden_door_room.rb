module T10
  module Rooms
    class HiddenDoorRoom < Room
      DOORS = 3

      def initialize
        @has_left = true
        @has_right = true
        @has_ahead = false
      end

      def desc_name
        "hidden door room"
      end
    end
  end
end

