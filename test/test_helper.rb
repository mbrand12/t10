require 'minitest/autorun'
require 'minitest/reporters'
require 't10'

Minitest::Reporters.use!

class T10::Room
  def to_str
    "#{self.class}\n" + @doors.map do |k, v|
      "#{k}, #{v[1]}\t, #{v[2].class}\n"
    end.join + "\n ================== \n"

  end

  def test_connections
    @doors.all? do |k, v|
      v[2] ? v[2].leads_to?(self.class, k): true
    end
  end

  protected

  def leads_to?(room_class, room_crest)
    @doors.any? do |k, v|
      v[2].class == room_class && k == orient(room_crest)
    end
  end

  private

  def orient(room_crest)
    case room_crest
    when :e_dragon
      :w_tiger
    when :s_phoenix
      :n_turtle
    when :w_tiger
      :e_dragon
    when :n_turtle
      :s_phoenix
    end
  end

end

class R11 < T10::Room
  DOORS = 1
  def initialize
    @has_left = false
    @has_right = false
    @has_ahead = false
  end
end

class R12 < T10::Room
  DOORS = 1
  def initialize
    @has_left = false
    @has_right = false
    @has_ahead = false
  end
end

class R13 < T10::Room
  DOORS = 1
  def initialize
    @has_left = false
    @has_right = false
    @has_ahead = false
  end
end

class R14 < T10::Room
  DOORS = 1
  def initialize
    @has_left = false
    @has_right = false
    @has_ahead = false
  end
end

class EndRoom < T10::Room
  DOORS = 1
  def initialize
    @has_left = false
    @has_right = false
    @has_ahead = false
  end
end

class Entrance < T10::Room
    DOORS = 2
  def initialize
    @has_left = false
    @has_right = false
    @has_ahead = true
  end
end

class R21 < T10::Room
  DOORS = 2
  def initialize
    @has_left = false
    @has_right = true
    @has_ahead = false
  end
end

class R22 < T10::Room
  DOORS = 2
  def initialize
    @has_left = false
    @has_right = false
    @has_ahead = true
  end
end

class R23 < T10::Room
  DOORS = 2
  def initialize
    @has_left = true
    @has_right = false
    @has_ahead = false
  end
end

class R31 < T10::Room
  DOORS = 3
  def initialize
    @has_left = true
    @has_right = true
    @has_ahead = false
  end
end

class R32 < T10::Room
  DOORS = 3
  def initialize
    @has_left = true
    @has_right = false
    @has_ahead = true
  end
end

class R4 < T10::Room
  DOORS = 4
  def initialize
    @has_left = true
    @has_right = true
    @has_ahead = true
  end
end
