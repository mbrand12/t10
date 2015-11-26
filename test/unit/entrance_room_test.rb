require 'test_helper'

class EntranceRoomTest < Minitest::Test

  def setup
    @en_room = T10::Rooms::EntranceRoom.new
    @next_room = T10::Room.new
    @hero = T10::Hero.new

    @en_room.prepare_entrance!
    @en_room.connect_to(@next_room)

  end

  def test_entering_room
    @en_room.interact([:enter], [], [@hero])
    assert @en_room.hero_here?,
      "Hero should be in the entrance room if Hero didn't visited before"
  end

  def test_exiting_room
    @en_room.interact([:enter], [], [])
    @en_room.interact([:exit], [:gate], [])
    assert !@en_room.hero_here? && @next_room.hero_here?,
      "Hero should be in the next room after exiting the entrance."
  end

  def test_entering_entrace_room_again
    @next_room.instance_variable_set(:@hero, @hero)
    @en_room.instance_variable_set(:@hero, nil)

    @en_room.interact([:enter], [], [])
    @next_room.interact([:exit], [], [:origin])
    @next_room.interact([], [], [:no])

    assert !@en_room.hero_here? && @next_room.hero_here?,
      "Hero should not be in the entrance room after the Hero has exited it."
  end

  def test_extiting_path
    @en_room.interact([:exit], [:path], [])

    refute @en_room.hero_here? && @next_room.hero_here?,
      "Hero shouldn't be in any room once the Hero has walked the path"
  end

  def test_no_satchel
    assert @hero.satchel.nil?,
      "Hero shouldn't have the satchel before entering the dungeon."
  end
end
