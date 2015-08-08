require 't10/story'
require 't10/book'

module T10
  class SaveEvent

    MODIFIERS = {
      yes: %i(yes remember),
      no:  %i(no not)
    }

    attr_reader :get_back_data, :complete

    def initialize(verb, nouns, modifiers)
      @complete = false
      @get_back_data = [verb, nouns, modifiers]
    end

    def interact(verb, nouns, modifiers)
      send(:save, nouns, modifiers)
    end

    def intro
      [] << Book.save_event[:save_intro]
    end

    def words
      [{},{},MODIFIERS]
    end

    private

    def save(nouns, modifiers)
      desc = []
      if modifiers.include?(:yes)
        Story.save_adventure
        @complete = true
        @get_back_data[2] << Book.save_event[:save_confirmed]
      elsif modifiers.include?(:no)
        @complete = true
      else
        desc << Book.save_event[:save_wrong_answer]
      end
    end
  end
end
