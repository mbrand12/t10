module T10
  module Rooms
    class HiddenDoorRoom < Room
      DOORS = 3

      def initialize
        super
        @has_left = true
        @has_right = false
        @has_ahead = true
      end

      def desc_name
        "hidden door room"
      end
    end
  end
end

