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
    room2 = R22.new

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
    hero = T10::Hero.new
    room1 = R21.new
    room2 = R13.new

    room1.connect_to(nil)
    room1.connect_to(room2)

    desc = []
    room1.hero = hero
    hero.damage(1)
    room1.interact([:exit], [], [:to_right])

    assert room2.hero_here?,
      "Hero should be in the second room, after exiting the first one."

    refute room1.hero_here?,
      "Hero should not be in the first room, after exiting from it"

  end

  def test_exiting_room_no_direction
    room1 = R21.new
    room2 = R11.new

    room1.connect_to(nil)
    room1.connect_to(room2)

    assert room1.interact([:exit],[],[])[0].match(/which/),
      "If no direction is provided method must return appropriate description."
  end

  def test_cracked_orb
    hero = T10::Hero.new
    hero.instance_variable_set(:@luck, 1000)

    room1 = R32.new
    room2 = R4.new

    room1.connect_to(nil)
    room1.connect_to(room2)

    desc = []
    room1.hero = hero
    hero.damage(1)
    desc.concat room1.interact([:exit], [], [:to_left])

    assert desc.any? {|d| d.match(/cracks/)}

    desc = []
    hero.damage(1)
    desc.concat room2.interact([:exit], [], [:origin])

    assert desc.any? {|d| d.match(/cracked/)},
      "Hero should not be healed again if the orb in the hallway is cracked " \
      "from when Hero came from #{room1.class} to this #{room2.class} room."

  end
end

