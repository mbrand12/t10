require 't10/story'
module T10
  class SaveEvent

    MODIFIERS = {
      yes: %i(yes remember),
      no:  %i(no)
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
      [] << "As I am exiting the room I begin to wonder: " \
            "\"Should I remember my adventure up to this point or not. \""
    end

    private

    def save(nouns, modifiers)
      desc = []
      if modifiers.include?(:yes)
        Story.save_adventure
        @complete = true
        @get_back_data[2] << "A feeling washes over me, as if I am going to " \
                             "remember this adventure, up to this point, " \
                             "for quite some time."
      elsif modifiers.include?(:no)
        @complete = true
      else
        desc << "Hmm, the answer to this one should be either yes or no."
      end
    end
  end
end
