module T10
  # The methods in this module are used to connect a {Room} to another {Room}
  # while ensuring that the connection goes both ways and takes care of
  # internal and external orientations. The connection is assigned to the
  # {Room} instance variable @door.
  #
  # Each room can have up to 4 doors, each door takes one cardinal direction
  # and requires that the room connected to that door follows that logic. In
  # other words if one exits via the east door it will come in the next room
  # via the west entrance.
  #
  # An origin door leads to the room that leads to the {Rooms::EntranceRoom}
  # (the first "room" in the dungeon). The origin door provides the means of
  # internal orientation without being dependent on the external orientation.
  # The narration in the room should always be made with that in mind (write
  # the description as if the Hero is always with his back turned on the origin
  # door).
  #
  # So regardless of external orientation of the room (east, west, north,
  # south) the internal orientation will always be the same. That way if a
  # specific room always has a door on the left it will have it regardless of
  # its external orientation (or rotation).
  #
  # An example of the @doors instance variable that holds the connections:
  #
  #     # The keys are the external orientation.
  #     # The second value is the internal rotation that is relative to the
  #     # :origin. The :ahead will always be the opposite cardinal direction
  #     # from the : origin, same with :to_right and :to_left. So if the :origin
  #     # is :w_tiger (west) the :ahead is :e_dragon (east).
  #     #
  #     # The third value is the reference to the instance of the room the
  #     # door leads to. Weather the value gets assigned here is dependent on
  #     # weather the room has that door via the @has_left, @has_right, and
  #     # @has_ahead boolean instance variables.
  #     @doors = {
  #        e_dragon:  [false, :ahead, nil],
  #        s_phoenix: [false, :to_right, nil],
  #        w_tiger:   [false, :origin, origin_room],
  #        n_turtle:  [false, :to_left, nil]
  #     }
  #
  # These methods are used only when generating the dungeon.
  module RoomConnectingTools
    # Connects one room to another where the receiver is the origin room (the
    # `room` parameter's origin door will point to this room). If the `room`
    # parameter is nil then the external orientation is randomly selected (the
    # only case for this is for the {Rooms::EntranceRoom})
    #
    # This is the only method that should be called in order to connect the
    # rooms.
    #
    # First the room (parameter) in question is added to the @doors of the
    # origin room (receiver), based
    # on weather the room has any empty doors to fill see
    # {RoomConnectingTools#add_door_leading_to} for more details.
    #
    # Then the origin door is added to the room's @door instance variable
    # and the variable internal orientation is set based on the origin room's
    # crest leading to that room.
    #
    # @param room [Room] The room that gets assigned its origin door.
    # @return [Room] the room that was assigned its origin door.
    def connect_to(room = nil)
      return add_origin_door unless room

      crest_to_room = add_door_leading_to(room)
      @doors[crest_to_room][2].add_origin_door(self, crest_to_room)
    end

    protected

    # Method adds the origin door to the room (receiver) based on the provided
    # crest from the origin room (parameter). The method is called in
    # {RoomConnectingTools#connect_to} and comes after
    # {RoomConnectingTools#add_door_leading_to}.
    #
    # The method raises an exception if the room first gets an origin door
    # before the origin room adds the room to the @door. This prevents from
    # the room having an origin door to a room which do not have the reference
    # to that room (in case the origin room has it slots full with other rooms
    # for example).
    #
    # If the origin room is not provided the method samples a direction
    # from list and setups the internal orientation based on that. Otherwise
    # it will use the crest from the origin room leading to room (receiver).
    #
    # @param origin_room [Room] The room that leads to receiver.
    # @param crest_to_room [Symbol] The external orientation leading to
    #                               receiver.
    # @raise [StandardError] if the origin room doesn't lead to the receiver.
    # @return [Room] the receiver.
    def add_origin_door(origin_room = nil, crest_to_room = nil)
      if origin_room && !crest_to_room
        fail StandardError,
             "#{origin_room} should lead to this (#{self.class} room) " \
             "before #{self.class} can lead to #{origin_room}"
      end

      unless origin_room
        crest_to_room = [:e_dragon, :s_phoenix, :w_tiger, :n_turtle].sample
      end

      case crest_to_room
      when :e_dragon
        @doors = {
          e_dragon:  [false, :ahead, nil],
          s_phoenix: [false, :to_right, nil],
          w_tiger:   [false, :origin, origin_room],
          n_turtle:  [false, :to_left, nil]
        }
      when :s_phoenix
        @doors = {
          e_dragon:  [false, :to_left, nil],
          s_phoenix: [false, :ahead, nil],
          w_tiger:   [false, :to_right, nil],
          n_turtle:  [false, :origin, origin_room]
        }
      when :w_tiger
        @doors = {
          e_dragon:  [false, :origin, origin_room],
          s_phoenix: [false, :to_left, nil],
          w_tiger:   [false, :ahead, nil],
          n_turtle:  [false, :to_right, nil]
        }
      when :n_turtle
        @doors = {
          e_dragon:  [false, :to_right, nil],
          s_phoenix: [false, :origin, origin_room],
          w_tiger:   [false, :to_left, nil],
          n_turtle:  [false, :ahead, nil]
        }
      end
      self
    end

    # This method adds the room (parameter) to the @doors of the receiver
    # (origin room). This method is called by the
    # {RoomConnectingTools#connect_to}.
    #
    # This method does not handle exceptions, it requires client to know
    # the total number of available doors and the number of occupied door by
    # checking the subclass {Room::DOORS} constant.
    #
    # After adding the method in the free slot of the @doors determined by the
    # @has_left, @has_right and @has_ahead (as well as the DOORS constant) of
    # the {Room}, the method returns the crest (or external orientation) of the
    # door that leads to the room (parameter).
    #
    # @param room [Room] A room to be added to @doors of the origin_room.
    # @raise [StandardError] if there are more than one room of the same class.
    # @raise [StandardError] if all doors are occupied.
    # @return [Symbol] The crest of the door leading to room (parameter)
    def add_door_leading_to(room)
      if @doors.find { |_, v| v[2].class == room.class }
        fail StandardError, "Duplicate rooms now allowed!"
      end

      left_crest  = get_crest_from_relative(:to_left) if @has_left
      right_crest = get_crest_from_relative(:to_right) if @has_right
      ahead_crest = get_crest_from_relative(:ahead) if @has_ahead

      case
      # does the room have a door to the left and is that door not occupied?
      when @has_left && @doors[left_crest][2].nil?
        @doors[left_crest][2] = room
        left_crest
      when @has_right && @doors[right_crest][2].nil?
        @doors[right_crest][2] = room
        right_crest
      when @has_ahead && @doors[ahead_crest][2].nil?
        @doors[ahead_crest][2] = room
        ahead_crest
      else
        fail StandardError,
             "All doors for room #{self.class} occupied." \
             " #{room.class} not added."
      end
    end

    private

    def get_crest_from_relative(orientation)
      @doors.find { |_, v| v[1] == orientation }[0]
    end
  end
end
