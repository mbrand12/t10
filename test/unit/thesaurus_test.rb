require 'test_helper'

class ThesaurusTest < Minitest::Test
  def setup
    @thesaurus = T10::Thesaurus

    @sample_verbs = {
      go: %i(go walk move),
      look: %i(look stare glare fixate)
    }
    @sample_nouns = {
      cat: %i(cat kitty tabby),
      dragon: %i(dragon)
    }
    @sample_modifiers = {
    }

    T10::Thesaurus.add_words(@sample_verbs, @sample_nouns, @sample_modifiers)
  end

  def test_scan_woking_properly
      text = "walk! dragon t@ab!by n,@ow!"

      verbs, nouns, modifiers = @thesaurus.scan(text)

      assert verbs, [:go]
      assert nouns, [:cat,:dragon]
  end

  def test_scan_empty
     text = "pat dog now!"

     verbs, nouns, modifiers = @thesaurus.scan(text)

     assert verbs, []
     assert nouns, []
     assert modifiers, [:no_words]
  end
end
