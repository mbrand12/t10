require "t10/rooms/under_construction"

module T10
  module Rooms
    class MachineryRoom < Room
      include Rooms::UnderConstruction

      DOORS = 3

      def initialize
        super
        @has_left = true
        @has_right = true
        @has_ahead = false
      end

      def desc_name
        "machinery"
      end
    end
  end
end
