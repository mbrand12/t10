require 'test_helper'

class BookTest < Minitest::Test
  def test_complain_if_there_is_no_file
    msg = "Should raise error when there is no file for the room or event"
    assert_raises(RuntimeError, msg) { T10::Book.no_room }
  end

  def test_room_text
    assert T10::Book.room[:orb_cracked].match(/ancient habit/),
      "The description should contain the phrase 'ancient habit'."
  end

  def test_event_text
    assert T10::Book.save_event[:save_intro].match(/remember/),
      "The description should contain the phrase."
  end
end
