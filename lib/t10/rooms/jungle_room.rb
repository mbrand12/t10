require "t10/rooms/under_construction"

module T10
  module Rooms
    class JungleRoom < Room
      include Rooms::UnderConstruction

      DOORS = 2

      def initialize
        super
        @has_left = true
        @has_right = false
        @has_ahead = false
      end

      def desc_name
        "jungle"
      end
    end
  end
end
