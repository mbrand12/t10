require 'minitest/autorun'
require 'minitest/reporters'
require 't10'

Minitest::Reporters.use!

class T10::Room
  # used for visual checking
  def to_str
    "#{self.class}\n" + @doors.map do |k, v|
      "#{k}, #{v[-2]}, #{v[0]}\t, #{v[-1].class}\n"
    end.join + "\n ================== \n"

  end

  # tests if the connections go both ways.
  def test_connections
    @doors.all? do |k, v|
      v[-1] ? v[-1].leads_to?(self.class, k): true
    end
  end

  protected

  def leads_to?(room_class, room_crest)
    @doors.any? do |k, v|
      v[-1].class == room_class && k == orient(room_crest)
    end
  end
end
