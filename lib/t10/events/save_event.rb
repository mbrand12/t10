require 't10/story'
require 't10/book'

module T10
  module Events
    # The save event is triggered every time the hero exits a room (except
    # during the exit of the {Rooms::EntranceRoom}), positive reply ends up in
    # game save.
    class SaveEvent < Event

      MODIFIERS = {
        yes: %i(yes remember),
        no:  %i(no not)
      }

      def initialize(verb, nouns, modifiers)
        super
      end

      # See {Event#interact}
      def interact(verb, nouns, modifiers)
        send(:save, nouns, modifiers)
      end

      # See {Event#intro}
      def intro
        [] << Book.save_event[:save_intro]
      end

      # See {Event#words}
      def words
        [{},{},MODIFIERS]
      end

      private

      def save(nouns, modifiers)
        if modifiers.include?(:yes)
          Story.save_adventure
          @complete = true
          Book.save_event[:save_yes]
        elsif modifiers.include?(:no)
          @complete = true
          Book.save_event[:save_no]
        else
          Book.save_event[:save_wrong_answer]
        end
      end
    end
  end
end
