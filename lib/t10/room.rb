module T10
  class Room

    DOORS = 4

    @rooms = []
    class << self
      attr_reader :rooms
    end

    def self.inherited(room_implementations)
      @rooms << room_implementations
    end

    def initialize
      @has_left  = false
      @has_right = false
      @has_ahead = false

      @doors = {
        e_dragon:  [false, nil, nil],
        s_phoenix: [false, nil, nil],
        w_tiger:   [false, nil, nil],
        n_turtle:  [false, nil, nil]
      }
    end

    def connect_to(room = nil )
      return add_origin_door unless room
      @doors[add_door(room)][2].add_origin_door(self)
    end


    protected

    def add_door(room)

      if @doors.find {|_, v| v[2].class == room.class}
        fail StandardError, "Duplicate rooms now allowed!"
      end

      left_crest  = get_crest_from_relative(:to_left)
      right_crest = get_crest_from_relative(:to_right)
      ahead_crest = get_crest_from_relative(:ahead)

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

    def add_origin_door(origin_room = nil)
      crest = nil
      if origin_room
        crest = origin_room.get_crest_leading_to(self)

        unless crest
          fail StandardError,
            "#{origin_room} should lead to this (#{self.class} room) before " \
            "#{self.class} can lead to #{origin_room}"
        end
      else
        crest = [:e_dragon, :s_phoenix, :w_tiger, :n_turtle].sample
      end

      case crest
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

    def get_crest_leading_to(room)
      door = @doors.find {|_, v| v[2].class == room.class}
      crest = door[0] if door
    end

    private

    def get_crest_from_relative(orientation)
      door = @doors.find { |_, v| v[1] == orientation}
      crest = door[0] if door
    end
  end
end

