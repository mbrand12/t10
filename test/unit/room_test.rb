require 'test_helper'

class RoomTest < Minitest::Test

  def test_adding_one_room_too_much
    room1 = T10::Rooms::EmptyRoom.new
    room2 = T10::Rooms::SimpleRoom.new

    room1.connect_to(nil)

    msg = "Room should not be able to be connected to the room that has" \
          "no doors left to be connected to."

    assert_raises(StandardError, msg) {room1.connect_to(room2)}
  end

  def test_adding_duplicate_rooms
    room1 = T10::Rooms::HiddenDoorRoom.new
    room2 = T10::Rooms::TrapRoom.new

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
    room1 = T10::Rooms::JungleRoom.new
    room2 = T10::Rooms::ArmorRoom.new

    room1.connect_to(nil)
    room1.connect_to(room2)

    desc = []
    room1.hero = hero
    hero.damage(1)
    room1.interact([:exit], [], [:to_right])
    room1.interact([],[],[:no])

    assert room2.hero_here?,
      "Hero should be in the second room, after exiting the first one."

    refute room1.hero_here?,
      "Hero should not be in the first room, after exiting from it"

  end

  def test_exiting_room_no_direction
    room1 = T10::Rooms::JungleRoom.new
    room2 = T10::Rooms::EmptyRoom.new

    room1.connect_to(nil)
    room1.connect_to(room2)

    assert room1.interact([:exit],[],[])[0].match(/which/),
      "If no direction is provided method must return appropriate description."
  end

  def test_cracked_orb
    hero = T10::Hero.new
    hero.instance_variable_set(:@luck, 1000)

    room1 = T10::Rooms::MachineryRoom.new
    room2 = T10::Rooms::HallRoom.new

    room1.connect_to(nil)
    room1.connect_to(room2)

    desc = []
    room1.hero = hero
    hero.damage(1)
    room1.interact([:exit], [], [:to_left])
    desc.concat room1.interact([],[],[:no])
    assert desc.flatten.any? {|d| d.match(/cracks/) if d.is_a?(String)}

    desc = []
    hero.damage(1)
    room2.interact([:exit], [], [:origin])
    desc.concat room2.interact([],[],[:no])

    assert desc.flatten.any? {|d| d.match(/cracked/) if d.is_a?(String)},
      "Hero should not be healed again if the orb in the hallway is cracked " \
      "from when Hero came from #{room1.class} to this #{room2.class} room."

  end

  def test_save_event

    story = T10::Story

    test_path = File.expand_path('../../data/save_event.yml', __FILE__)
    story.instance_variable_set(:@save_path, test_path)

    story.new_adventure
    story.current_room.interact([:enter],[],[])
    story.current_room.interact([:exit],[:gate],[])
    room1 = story.current_room

    desc = []
    room1.interact([:exit], [], [:origin])

    desc.concat room1.interact([],[],[:yes])

    assert desc.flatten.any? {|d| d.match(/washes/) if d.is_a?(String) },
      "Text should contain description of the save event."

    story.new_adventure
  end
end

