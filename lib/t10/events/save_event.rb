require 't10/story'
require 't10/book'

module T10
  module Events
    class SaveEvent  < Event

      MODIFIERS = {
        yes: %i(yes remember),
        no:  %i(no not)
      }

      def initialize(verb, nouns, modifiers)
        super
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
