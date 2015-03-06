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

  def test_words
    room = T10::Room.new
    assert_equal 3, room.words.length
  end

  def test_exiting_room
    room1 = R21.new
    room2 = R11.new

    room1.connect_to(nil)
    room1.connect_to(room2)

    desc = []
    desc.concat room1.interact([:exit], [], [:n_turtle])
    desc.concat room1.interact([:exit], [], [:e_dragon])
    desc.concat room1.interact([:exit], [], [:s_phoenix])
    desc.concat room1.interact([:exit], [], [:w_tiger])

    assert desc.any? {|d| d.match(/ROOM/)}
  end

  def test_exiting_room_no_direction
    room1 = R21.new
    room2 = R11.new

    room1.connect_to(nil)
    room1.connect_to(room2)

    assert room1.interact([:exit],[],[])[0].match(/which/),
      "If no direction is provided method must return appropriate description."

  end
end

