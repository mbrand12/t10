require 'test_helper'

class SimpleRoomTest < Minitest::Test
  def setup
    @rm =  T10::Rooms::SimpleRoom.new
  end

  def test_words
     @rm.words[1]
  end
end
