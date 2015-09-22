require "t10/rooms/under_construction"

module T10
  module Rooms
    class EmptyRoom < Room
      include Rooms::UnderConstruction

      DOORS = 1

      def initialize()
        super
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
