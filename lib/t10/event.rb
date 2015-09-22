module T10
  # @abstract This class is a placeholder for concrete event implementations.
  # An event is activated by hero's actions and is tied to the room the hero
  # is in. Some events are made just for a specific room ({Events::ArmorEvent})
  # others can be used in every room ({Events::SaveEvent}).
  #
  # The event class and its subclasses use the same interact/words interface as
  # the {Room}. See {Room#interact} for more details on that.
  class Event

    # The get_back_data holds instructions to what specific method to run after
    # the event is finished. For example a certain event in the
    # {Rooms::ArmorRoom} triggers an event:
    #
    #     @current_event = Events::ArmorEvent.new(:battle_over, [], [])
    #
    # The `:battle_over` is the method from the {Rooms::ArmorRoom} class that
    # will be called via {Room#interact} (or more precisely the send method
    # event_interact within). During the event the 3rd parameter (modifiers)
    # will be filled with flags (symbols) that will determine the outcome after
    # the event.
    #
    # @return [Array<Symbols>] a verbs, nouns, modifiers array populated
    #  during event creation.
    attr_reader :get_back_data

    # @return [Boolean] true if the event is complete.
    attr_reader :complete

    alias_method :complete?, :complete

    def initialize(verb, nouns, modifiers)
      @get_back_data = [verb, nouns, modifiers]
      @complete = false
    end

    # See {Room#interact}
    def interact(verbs, nouns, modifiers); fail NotImplementedError; end

    # See {Room#words}
    def words; fail NotImplementedError; end

    # @return [String] provides an introduction description for the event.
    def intro; fail NotImplementedError; end

    # @return [String] provides a closing description for the event.
    def outro; fail NotImplementedError; end
  end
  require 't10/events/save_event'
  require 't10/events/armor_event'
end
