require 'test_helper'

class StoryTest < Minitest::Test
  def setup
    @story = T10::Story
  end
  def test_no_save_file
    test_path = "no_file.yml"
    @story.instance_variable_set(:@save_path, test_path)

    msg = "should raise an exception if no file is found"
    assert_raises(RuntimeError, msg) { @story.new_adventure }
    assert_raises(RuntimeError, msg) { @story.save_adventure }
    assert_raises(RuntimeError, msg) { @story.load_adventure }
  end

  def test_wrong_file
    test_path = File.expand_path('../../data/not_save.yml', __FILE__)
    @story.instance_variable_set(:@save_path, test_path)

    refute @story.ongoing_adventure?,
      "Should return false when proper data is not found"
  end

  def test_empty_dungeon
    test_path = File.expand_path('../../data/empty_save.yml', __FILE__)
    @story.instance_variable_set(:@save_path, test_path)

    refute @story.ongoing_adventure?,
      "Should return false when there are no rooms in the dungeon."
  end
end
