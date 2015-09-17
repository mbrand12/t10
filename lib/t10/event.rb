module T10
  class Event
    attr_reader :get_back_data, :complete

    alias_method :complete?, :complete

    def initialize(verb, nouns, modifiers)
      @get_back_data = [verb, nouns, modifiers]
      @complete = false
    end

    def intro; fail NotImplementedError; end
    def outro; fail NotImplementedError; end
  end
  require 't10/events/save_event'
  require 't10/events/armor_event'
end
