require 't10/room'

module T10
  class Dungeon
    ROOM_TYPE_LIMIT = [0, 4, 3, 2, 1]

    @rooms_by_type = {
      door_1: [],
      door_2: [],
      door_3: [],
      door_4: []
    }

    @dungeon_rooms = []

    def self.generate
      populate_types
      shuffle_rooms

      starting_room = T10::Rooms::EntranceRoom.new
      @dungeon_rooms = [starting_room]
      @dungeon_rooms[0].connect_to(nil)

      @dungeon_rooms.each do |current_room|
        next if current_room.class::DOORS == 1

        sample_rooms_for(current_room).each do |sampled_room|
          @dungeon_rooms << current_room.connect_to(sampled_room.new)
        end
      end
      @dungeon_rooms
    end

    private

    def self.populate_types
      @rooms_by_type.each do |k, _|
        @rooms_by_type[k] =
          T10::Room.rooms.select { |r| r::DOORS == k.slice(5).to_i }
      end

      @rooms_by_type[:door_1].delete T10::Rooms::EndRoom
      @rooms_by_type[:door_2].delete T10::Rooms::EntranceRoom
    end

    def self.shuffle_rooms
      @rooms_by_type.each do |k, _|
        @rooms_by_type[k] =
          @rooms_by_type[k].shuffle.slice(0, ROOM_TYPE_LIMIT[k.slice(5).to_i])
      end

      if ROOM_TYPE_LIMIT.inject(:+) != number_of_rooms
        fail StandardError,
          "Number of rooms for generating must be the same as room type limit!"
      end
    end

    def self.number_of_rooms
      @rooms_by_type.map { |_, v| v.size }.inject(:+)
    end

    def self.sample_rooms_for(origin_room)
      room_1_limit = origin_room.class::DOORS - 2
      number_of_rooms_to_sample = origin_room.class::DOORS - 1

      sampled_rooms = []

      number_of_rooms_to_sample.times do
        if all_the_rooms_but_1rooms_are_sampled?
          room_1_limit += 1
        end

        permitted_room_types = @rooms_by_type.select { |_, v| !v.empty? }.keys

        if permitted_room_types.include?(:door_1) &&
          ( !dungeon_has_3room_or_4room_sampled? || room_1_limit < 1 )

          permitted_room_types.delete(:door_1)
        end

        sampled_room_type = permitted_room_types.sample

        if sampled_room_type == :door_1
          room_1_limit -= 1
        end

        if sampled_room_type
          sampled_rooms << @rooms_by_type[sampled_room_type].shift
        else
          sampled_rooms << T10::Rooms::EndRoom
        end
      end
      sampled_rooms
    end

    def self.dungeon_has_3room_or_4room_sampled?
      @dungeon_rooms.any? do |dungeon_room|
        room_doors = dungeon_room.class::DOORS
        room_doors == 3 || room_doors == 4
      end
    end

    def self.all_the_rooms_but_1rooms_are_sampled?
      @rooms_by_type.all? { |k, v| k == :door_1 ? true : v.empty? }
    end
  end
end
