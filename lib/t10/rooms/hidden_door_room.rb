require "t10/rooms/under_construction"

module T10
  module Rooms
    class HiddenDoorRoom < Room
      include Rooms::UnderConstruction

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

