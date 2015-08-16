module T10
  module RoomConnectingTools
    def connect_to(room = nil)
      return add_origin_door unless room

      crest_to_room = add_door_leading_to(room)
      @doors[crest_to_room][2].add_origin_door(self, crest_to_room)
    end

    protected

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

    def add_door_leading_to(room)
      if @doors.find { |_, v| v[2].class == room.class }
        fail StandardError, "Duplicate rooms now allowed!"
      end

      left_crest  = get_crest_from_relative(:to_left) if @has_left
      right_crest = get_crest_from_relative(:to_right) if @has_right
      ahead_crest = get_crest_from_relative(:ahead) if @has_ahead

      case
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
