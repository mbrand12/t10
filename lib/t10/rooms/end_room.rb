module T10
  module Rooms
    class EndRoom < Room
      DOORS = 1

      @has_left = false
      @has_right = false
      @has_ahead = false
    end
  end
end
