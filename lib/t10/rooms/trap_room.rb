require "t10/rooms/under_construction"

module T10
  module Rooms
    class TrapRoom < Room
      include Rooms::UnderConstruction

      DOORS = 2

      def initialize
        super
        @has_left = false
        @has_right = false
        @has_ahead = true
      end

      def desc_name
        "trap room"
      end
    end
  end
end
