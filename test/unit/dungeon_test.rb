require 'test_helper'

class DungeonTest < Minitest::Test
  def setup
    @generated_rooms = T10::Dungeon.generate
  end

  def test_room_connections
    # @generated_rooms.each {|room| puts room.to_str}
    assert @generated_rooms.all?(&:test_connections),
      "Rooms must be properly connected and oriented."
  end

  def test_room_connections_when_tampered_with
    doors = {
      e_dragon:  [false, :to_left, nil],
      s_phoenix: [false, :ahead, nil],
      w_tiger:   [false, :to_right, nil],
      n_turtle:  [false, :origin, nil]
    }
    room_sample = @generated_rooms.sample
    room_sample.instance_variable_set(:@doors, doors)

    refute @generated_rooms.all?(&:test_connections),
      "Testing room connections must fail when being tampered with."
  end

  def test_dungeon_containing_only_unique_rooms
    h = Hash.new(0)
    assert(
      @generated_rooms.all? { |r| h[r.class] > 1 ? false : h[r.class] += 1 },
      "Dungeon must contain unique rooms only."
    )
  end

  def test_dungeon_rooms_limit
    generated_rooms_limit = T10::Dungeon::ROOM_TYPE_LIMIT.inject(:+) + 2
    assert_equal generated_rooms_limit, @generated_rooms.size,
      "Number of generated rooms must be #{generated_rooms_limit}"
  end

  def test_entrance_and_end_rooms
    room_clases = @generated_rooms.map(&:class)
    assert room_clases.include?(Entrance) && room_clases.include?(EndRoom),
      "Dungeon must have an Entrance and Exit"
  end
end
