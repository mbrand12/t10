require 'test_helper'

class ThesaurusTest < Minitest::Test
  def setup
    @thesaurus = T10::Thesaurus

    @sample_verbs = {
      go: %i(go walk move),
      look: %i(look stare glare fixate)
    }
    @sample_nouns = {
      cat: %i(cat kitty tabby)
    }
    @sample_modifiers = {
    }
  end

  def test_scan_woking_properly
      text = "walk! t@ab!by n,@ow!"

      verbs, nouns, modifiers = @thesaurus.scan(text)

      assert verbs, [:go]
      assert nouns, [:cat]
  end

  def test_scan_empty
     text = "pat dog now!"

     verbs, nouns, modifiers = @thesaurus.scan(text)

     assert verbs, []
     assert nouns, []
     assert modifiers, [:no_words]
  end

end
