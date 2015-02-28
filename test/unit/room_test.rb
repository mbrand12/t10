require 'test_helper'

class RoomTest < Minitest::Test

  def test_adding_one_room_too_much
    room1 = R11.new
    room2 = R12.new

    room1.connect_to(nil)

    msg = "Room should not be able to be connected to the room that has" \
          "no doors left to be connected to."

    assert_raises(StandardError, msg) {room1.connect_to(room2)}
  end

  def test_adding_duplicate_rooms
    room1 = R31.new
    room2 = R11.new

    room1.connect_to(nil)
    room1.connect_to(room2)

    msg = "Should not allow adding duplicate rooms"
    assert_raises(StandardError, msg) {room1.connect_to(room2)}
  end
end
