require 't10/traversable'

module T10
  # @abstract This class is a placeholder for concrete room implementations.
  #
  # A room is a any place in the game where, trough text, the user can interact
  # with the environment, access events and satchel.
  #
  # The goal of the game is to pick the shiny piece in most of the rooms
  # (except in the {Rooms::EntranceRoom} and {Rooms::EndRoom}), combine it with
  # an amulet and use it to exit the dungeon.
  #
  # ## Constant notes
  #
  # {DOORS} is the maximum number of doors that a room can have. Each subclass
  # should define its own {DOORS} which will refer to the maximum of the doors
  # but that value must not be greater than 4.
  #
  # {VERBS} are a hash of keyword keys and synonym values that are used as
  # method calls trough {Room#interact}. A **verb method** should not be
  # called directly but trough {Room#interact} (or in the case of the {Event}
  # and {Satchel} trough their respective interact methods).
  #
  # {NOUNS} are a hash of the same structure as {VERBS} that are used for logic
  # control, accessing and returning descriptions in the {VERBS} methods.
  #
  # {MODIFIERS} are also a hash of the same structure as {VERBS} that are used
  # mostly for navigations, modifiers for the nouns (example "door of the left,
  # door on the right "), and specific flags and data passed from method to
  # method (although the last is to be avoided most if not all of the time).
  #
  # Every subclass of {Room} should have their constants as well for their
  # specific uses and merge them with the constants of the parent on request
  # (usually for filtering user input into verbs, nouns and modifiers).
  # The method used for that is {Room#words}.
  class Room
    include T10::Traversable

    DOORS = 4

    # Keyword and synonyms
    VERBS = {
      exit: %i(exit leave escape enter),
      enter: %i()
    }

    # Keyword and synonyms
    NOUNS = {
      door:    %i(door passage passageway enterance),
      satchel: %i(satchel inventory stash)
    }

    # The :east (dragon), :south (phoenix), :west (tiger) and :north (turtle)
    # are used for the external orientation.  For example: Enter the door with
    # the dragon crest.
    #
    # While the :to_left, :to_right, :ahead and :origin are used for internal
    # orientation. For example: Enter the leftmost door.
    MODIFIERS = {
      east:  %i(dragon),
      south: %i(phoenix),
      west:   %i(tiger),
      north:  %i(turtle),
      to_left:   %i(left leftmost),
      to_right:  %i(right rightmost),
      ahead:     %i(ahead straight forward),
      origin:    %i(back behind)
    }

    # Holds the list of all the classes that will inherit this class.
    @rooms = []
    class << self
      # Used as a rooms list for the dungeon generator.
      # @return [Array] list of all classes that inherit {Room}
      attr_reader :rooms
    end

    # Callback invoked whenever a class inherits the {Room}. Adds the subclass
    # to the @rooms.
    # @return [void]
    def self.inherited(room_implementations)
      @rooms << room_implementations
    end


    # Creates a new room.
    #
    # ## Instance variables overview
    #
    # - **@visited** - [Boolean] used to determine what text should be displayed
    #                when the Hero enters the room.
    # - **@has_left** - [Boolean] used for internal orientation. If a room
    #                 'narrative wise' has a door to the left then the value
    #                 is true. Same goes for @has_right and @has_ahead. Every
    #                 room must have an origin.
    # - **@doors** - [Hash] the key is the external orientation keyword the
    #                first value is the status of the healing orb in the hallway
    #                between this room and the room that it will connect to.
    #                The second value is the name of the crest used in
    #                descriptions.
    # - **@current_event** [{Event}] it holds the reference to the currently
    #                      triggered event, during which all the user input is
    #                      directed to the {Event#interact} trough
    #                      {Room#interact}.
    # - **@room_items** [Array<Constant>] holds the items that can be picked up
    #                   in this room. The array holds the class names of the
    #                   items.
    # - **@key_item_slots** [Hash] holds the item keyword as a key and nouns
    #                       needed for its use in the values. See
    #                       {Rooms::EndRoom#initialize} source for the example.
    # - **@shiny_obtained** [Boolean] true if the hero has obtained the shiny
    #                       piece in this room. Used mostly to change the look
    #                       of the command prompt, and to activate events.
    def initialize
      @visited = false

      @has_left  = false
      @has_right = false
      @has_ahead = false

      @doors = {
        east:  [false, :dragon],
        south: [false, :phoenix],
        west:  [false, :tiger],
        north: [false, :turtle]
      }

      @hero = nil

      @current_event = nil

      @room_items = []
      @key_item_slots = {}
      @shiny_obtained = false
    end

    # Method used to get room name for the display in the command prompt.
    #
    # @return [String] the room name.
    def desc_name; fail NotImplementedError; end

    # Method is used to check weather the Hero is in room. If the hero is in
    # neither room then it is a game over, it is also used to determine which
    # of the rooms {Room#interact} should be used.
    #
    # @return [Boolean] true if the Hero is in this room
    def hero_here?
      true if @hero
    end

    # Method returns the array of hashes that is used then in conjunction with
    # the user input text to find the allowed keywords. See {Book} for more
    # info. Only when the user input is filtered is the {Room#interact} method
    # called.
    #
    # When the Hero is in the event a different set of words is used. Once the
    # satchel is obtained the words from {Satchel} are used as well.
    #
    # Each subclass should implement their own words method and call a super to
    # combine the total number of allowed words  See
    # {Rooms::EntranceRoom#words} source for the general idea.
    #
    # @return [Array<Hash>] an array of hashes with keywords as keys and
    #                       synonyms as values. See {VERBS} for the structure.
    def words
      if @current_event
        @current_event.words
      elsif @hero && @hero.satchel
        verbs, nouns, mods = @hero.satchel.words
        nouns = nouns.merge(get_room_items_words)
        [VERBS.merge(verbs), NOUNS.merge(nouns), MODIFIERS.merge(mods)]
      else
        [VERBS, NOUNS.merge(get_room_items_words), MODIFIERS]
      end
    end

    # Probably the most important method here. Each class that relies on the
    # user input must have this method as well as words and the verbs, nouns,
    # modifiers constants. Those are {Room} and its subclasses, {Event} and its
    # subclasses and {Satchel}.
    #
    # The use case is:
    # - user inputs text
    # - the text gets filtered using the words method
    # - the result is send to interact
    # - the verb determines the (verb) method called
    # - stuff happens
    # - user gets a description
    #
    # This method should not be overwritten since it also handles the event and
    # satchel interact. When there is an event the method calls
    # `event_interact` where the method then calls the interact method of the
    # {Event#interact}, same goes for the satchel. The `@current_event` causes
    # the `event_interact` call while the `:satchel` noun keyword causes the
    # method to call `satchel_interact`.
    #
    # @param verbs [Array<Symbol>]  a list of accepted keyword verb words
    # @param nouns [Array<Symbol>]  a list of accepted keyword noun words
    # @param modifiers [Array<Object>]  a list of accepted keyword modifiers,
    #   can also include method specific objects.
    # @return [Array<String>, String] A description or an array of descriptions.
    def interact(verbs, nouns, modifiers)
      @current_event = nil if modifiers.include?(:game_load)

      if @current_event
        event_interact(verbs, nouns, modifiers)
      elsif nouns.include?(:satchel)
        satchel_interact(verbs, nouns, modifiers)
      elsif verbs.empty? ||
            [:inspect, :put, :use, :combine].include?(verbs[0]) ||
            modifiers.include?(:no_words)
        Book.room[:no_words]
      else
        send(verbs[0], nouns, modifiers)
      end
    end

    protected

    # This method is called when the item is used in the room. It allows
    # subclasses to provide specific descriptions and trigger different events
    # or flags.
    #
    # @param item_class [Constant] a class of the item.
    # @return [Array<String>, String] a description of the item use.
    def item_used(item_class); fail NotImplementedError; end

    # This method is called when the item is taken from the room. It allows the
    # subclasses to provide specific descriptions and trigger different events
    # or flags.
    #
    # @param item_class [Constant] a class of the item.
    # @return [Array<String>, String] a description of the item taken.
    def item_obtained(item_class); fail NotImplementedError; end

    # Method triggers when a Hero enters this room (usually as a result of an
    # {Room#exit} from the other room).
    #
    # @param nouns [Array<Symbol>] a list of accepted noun words.
    # @param modifiers [Array<Symbol, Object>] a list of accepted modifiers as
    #   well as method specific objects or symbols.
    # @return [Array<String>, String] a description of the room upon entering.
    def enter(nouns, modifiers)
      @hero = modifiers.pop if modifiers.last.is_a?(Hero)
      if modifiers.include?(:cracked)
        @doors[get_crest_from_absolute(modifiers.pop)][0] = true
      end
      desc = []
    end

    # This is a verb method meaning that it should be called trough
    # {Room#interact}.
    #
    # This method is called when the Hero leaves the room. The Hero then goes to
    # the other room trough the hallway. During that the user is presented with
    # an option to save the game and with a chance for the onetime heal using
    # the orb in the hallway. The status of the orb is kept in the first value
    # of the hash @doors.
    #
    # The save prompt is implemented as an event (see {Events::SaveEvent}).
    #
    # The method first activates an event then after the event finishes it checks
    # the heal chance, then calls the {Room#interact} with verb enter to get
    # the description of the other room and transfer the hero instance there is
    # applicable.
    #
    # This method should overview but always called as super by the subclass.
    #
    # @param nouns [Array<Symbol>] a list of accepted noun words.
    # @param modifiers [Array<Symbol, Object>] a list of accepted modifiers as
    #   well as method specific objects or symbols.
    # @return [Array<String>, String] a description of the action of exiting the
    #   room.
    def exit(nouns, modifiers)
      desc = []
      door = get_door_data(modifiers)

      unless door
        return Book.room[:which_door]
      end
      crest, orb_cracked, _, _, next_room = door

      unless next_room
        return Book.room[:sealed_door]
      end

      if @current_event == nil && !modifiers.include?(:no_save)
        @current_event = Events::SaveEvent.new(:exit, nouns, modifiers)
        return @current_event.intro
      end
      nroom_modifiers = []

      @current_event = nil if @current_event && @current_event.complete?

      desc.concat orb_chance(orb_cracked)
      if desc.pop
        @doors[crest][0] = true
        nroom_modifiers << :cracked << crest
      end
      nroom_modifiers << @hero
      @current_event = nil
      desc << next_room.interact([:enter], [], nroom_modifiers)
      @hero = nil if next_room.hero_here?
      desc
    end

    # Method used internally between rooms used to get the key value of the
    # hash @doors base on the second value in the value array.
    #
    # @param orientation [Symbol] one of the [:to_left, :to_right, :ahead,
    #   :origin] symbols.
    # @return [Symbol] one of the [:dragon, :tiger, :turtle, :phoenix]
    #   symbols.
    def get_desc_crest_from_relative(orientation)
      door = @doors.find { |_, v| v[-2] == orientation }
      door.flatten[2] if door
    end

    private

    def get_room_items_words
      return {} if @room_items.empty?

      result_hash = {}
      @room_items.each { |item| result_hash.update(item.item_words) }
      result_hash
    end

    def event_interact(verbs, nouns, modifiers)

      desc = [@current_event.interact(verbs, nouns, modifiers)]

      if @current_event.complete
        e_verb, e_nouns, e_modifiers = @current_event.get_back_data
        return desc << send(e_verb, e_nouns, e_modifiers)
      end
      desc
    end

    def satchel_interact(verbs, nouns, modifiers)
      nouns -= [:satchel]

      if verbs.include?(:put)
        modifiers = @room_items.map(&:item_name)
      elsif verbs.include?(:use)
        modifiers = key_item_fits(nouns)
      end

      desc = @hero.satchel.interact(verbs, nouns, modifiers)

      if desc.is_a?(Array) && desc.last.is_a?(Symbol)
        symbol = desc.pop

        if removed_item_class = remove_item(symbol)
          desc << item_obtained(removed_item_class)
        elsif key_item_class = remove_key_item_slot(symbol)
          desc << item_used(key_item_class)
        end
        @shiny_obtained = true if symbol == Items::ShinyItem.item_name
      end
      desc
    end

    def key_item_fits(nouns)
      key_item_words = @key_item_slots.find { |k, _| nouns.include?(k) }
      return [] unless key_item_words

      if nouns.any? { |noun| key_item_words[1].include?(noun) }
        [key_item_words[0]]
      else
        []
      end
    end

    def remove_item(item_name)
      deleted = []
      @room_items.delete_if do |item|
        deleted << item if item.item_name == item_name
      end
      deleted.first
    end

    def remove_key_item_slot(item_name)
      deleted = []
      @key_item_slots.delete_if do |k, _|
        deleted << k if k == item_name
      end
      deleted.first
    end

    def get_crest_from_absolute(other_room_crest)
      door = @doors.find { |k, _| k == orient(other_room_crest) }
      door[0] if door
    end

    def get_door_data(modifiers)
      door = @doors.find do |k, v|
        modifiers.include?(k) || modifiers.include?(v[-2])
      end
      return nil unless door
      door.flatten
    end

    def orb_chance(orb_cracked)
      if orb_cracked
        [Book.room[:orb_cracked], false]
      elsif !orb_cracked && !@hero.at_full_health? && @hero.chance_heal(1)
        orb_text = Book.room[:orb_heal] % [hit_points: @hero.hit_points]
        [orb_text, true]
      else
        [Book.room[:orb_no_heal], false]
      end
    end

    def orient(room_crest)
      case room_crest
      when :east
        :west
      when :south
        :north
      when :west
        :east
      when :north
        :south
      end
    end
  end
  require 't10/rooms/entrance_room'
  require 't10/rooms/end_room'
  require 't10/rooms/armor_room'
  require 't10/rooms/boss_room'
  require 't10/rooms/empty_room'
  require 't10/rooms/hall_room'
  require 't10/rooms/hidden_door_room'
  require 't10/rooms/jungle_room'
  require 't10/rooms/machinery_room'
  require 't10/rooms/maze_room'
  require 't10/rooms/simple_room'
  require 't10/rooms/trap_room'
end
