module T10
  # This class provides inventory feature trough the similar interface that the
  # subclasses of {Room} and {Event} use. It provides basic operations in order
  # to manipulate items ({Item} subclasses) such as inspecting the item,
  # putting the item in the satchel, combining the item and using the item. The
  # methods for the manipulation should not be accessed directly but trough
  # {Satchel#interact}.
  class Satchel
    # Holds the allowed verb keywords and its corresponding synonyms. The
    # synonyms are used when scanning user input and the keywords correspond to
    # the method names.
    VERBS = {
      inspect: %i(inspect),
      put: %i(put place pick),
      use: %i(use),
      combine: %i(combine)
    }

    NOUNS = {}

    MODIFIERS = {}

    # Adds amulet item upon creation and adds it to the @inventory. The
    #   @recipes hash holds the result of combination as a key and the
    # ingredients as a value.
    def initialize
      @inventory = []
      add_item(Items::AmuletItem.item_name)

      @recipes = {
        Items::AmuletItem.item_name =>
           [
             Items::AmuletItem.item_name,
             Items::ShinyItem.item_name
           ].sort
      }
    end

    # This method provides the necessary keywords and synonyms array of hashes
    # that are then used to match the user input.
    #
    # @return [Array<Hash>] An array of the hash of keywords and synonyms.
    def words
      [VERBS, NOUNS.merge(get_inventory_words), MODIFIERS]
    end

    # This method accepts the allowed verbs, nouns and modifiers and calls
    # the respective methods based on the first verb. Since the verbs that
    # are used for matching are combined with verbs from the {Room} subclass
    # the method first removes those symbols not found in {VERBS} key values.
    # See {Room#interact} for more details.
    #
    # @param verbs [Array<Symbol>] An array of accepted verbs from user input.
    # @param nouns [Array<Symbol>] ^ see above.
    # @param modifiers [Array<Symbol>] An array of symbols which vary based
    #                                  the verb.
    # @return [String] a description of the action performed by the verb.
    def interact(verbs, nouns, modifiers)
      verbs.each { |v| verbs.delete(v) unless VERBS.keys.include?(v) }
      return help if verbs.empty?
      send(verbs.first, nouns, modifiers)
    end

    protected

    # This method is used to return descriptions of the items in the satchel
    # and it is meant to be accessed trough {Satchel#interact}, same goes for
    # {Satchel#put}, {Satchel#combine}, {Satchel#use}.
    #
    # The method searches the items in @inventory that matches via `find_item`
    # private method and returns a description of the found item.
    #
    # @param nouns [Array<Symbol>] An array of accepted nouns from user input.
    # @return [String] A description of the item.
    def inspect(nouns, _modifiers)
      if nouns.empty?
        [Book.satchel[:inspect_blank], list_item_names]
      elsif item = find_item(nouns)
        item.desc
      else
        [Book.satchel[:inspect_blank],  list_item_names]
      end
    end

    # This method is used to put the items from the rooms in the @inventory and
    # it is meant to be accessed trough {Satchel#interact}.
    #
    # The modifiers parameter should be filled with keywords from the items
    # the room contains (or that can be obtained in that room). This method then
    # compares the keywords in the modifiers with keywords in nouns to see
    # if the item that should be put is in the room and then informs the player
    # of the action.
    #
    # @param nouns [Array<Symbol>] An array of accepted nouns from user input.
    # @param modifiers [Array<Symbol>] An array of item keywords that the
    #                                  current room has.
    # @return [String] A description of the item.
    def put(nouns, modifiers)
      return Book.satchel[:put_blank] if nouns.empty?

      item_word = room_contains_item(nouns, modifiers)

      if item_word && item = add_item(item_word)
        desc = [Book.satchel[:put_item] % [item_name: item.desc_put]]
        desc << item_word
      else
        Book.satchel[:put_already]
      end
    end

    # This method is used to use the items from the @inventory in a room and
    # it is meant to be accessed trough {Satchel#interact}.
    #
    # The item can only be used if the item is in the @inventory and if it is a
    # key item (which is assigned to modifiers from `@key_item_slots` from
    # {Room}) and if the current {Item} quality matches the max quality.
    #
    # Example of user input:
    #
    #     Use(verb) amulet(noun) from the satchel(noun) on the wall(modifier).
    #
    #  The noun "satchel" is used to trigger {Satchel#interact}, while the
    #  "wall" serves as a modifier received from the @key_item_slots variable
    #  of the {Room}, or more precisely {Rooms::EndRoom}.
    #
    # @param nouns [Array<Symbol>] An array of accepted nouns from user input.
    # @param modifiers [Array<Symbol>] An array of item keyword slots from the
    #                            current room.
    # @return [String, Array<String,Symbol>] A descriptions of the item use
    #                                        and the keyword of the item used.
    def use(nouns, modifiers)
      return Book.satchel[:use_blank] if nouns.empty?
      return Book.satchel[:use_cant_there] if modifiers.empty?

      if nouns.include?(modifiers[0]) && item = find_item(nouns)
        if item.quality == item.max_quality
          remove_item(item)
          desc = [Book.satchel[:use_item] % [item_name: item.desc_name]]
          desc << modifiers[0]
        else
          Book.satchel[:use_cant_yet]
        end
      else
        Book.satchel[:use_already]
      end
    end

    # This method is used for combining the items in the @inventory into either
    # a new item or to increase the quality of an existing item while removing
    # one item or in case of the new item both items. The method is meant to be
    # accessed trough {Satchel#interact}.
    #
    # The method can only combine 2 items and only if the keywords for the
    # items in questions are included in the @recipes value array. The method
    # then deletes the used item (or items) and increases the quality of the
    # item (or keep the default one if it is a new item).
    #
    # Example of user input:
    #
    #      "Combine(verb) amulet(noun) with the shiny(noun) pieces(noun) from
    #      the satchel(noun)."
    #
    # The "satchel" is a trigger word to call {Satchel#interact} while
    # "shiny", "pieces" are synonyms for the noun keyword :shiny.
    #
    # @param nouns [Array<Symbol>] An array of accepted nouns from user input.
    # @return [String] A description for the combined item.
    def combine(nouns, _modifiers)
      inv_words = get_inventory_words.keys
      nouns.delete_if { |noun| !inv_words.include?(noun) }

      return Book.satchel[:combine_not_enough] if nouns.length < 2
      return Book.satchel[:combine_too_many] if nouns.length > 2

      if recipe_hash = get_recipe(nouns)
        item_1 = find_item([recipe_hash[1][0]])
        item_2 = find_item([recipe_hash[1][1]])
        result_item = find_item([recipe_hash[0]])

        @inventory.delete(item_1) if recipe_hash[0] != recipe_hash[1][0]
        @inventory.delete(item_2) if recipe_hash[0] != recipe_hash[1][1]

        new_q_or_q = 0

        if result_item
          if result_item.class == item_1.class &&
             result_item.class == item_2.class

            new_q_or_q = item_1.quantity + item_2.quantity -
                         result_item.quantity
            result_item.increase_quantity(new_quantity)
          elsif result_item.class != item_1.class
            new_q_or_q = item_1.quantity
            result_item.increase_quality(new_q_or_q)
          else
            new_q_or_q = item_2.quantity
            result_item.increase_quality(new_q_or_q)
          end
          result_item.desc_combined(new_q_or_q)
        else
          item = add_item(recipe_hash[0])
          Book.satchel[:combine_new] % [item_name: item.desc_name]
        end
      end
    end

    private

    def add_item(item_name)
      if item = item_already_added?(item_name)
        item.increase_quantity
        return item
      end

      item = get_class_from_item_name(item_name).new
      @inventory << item
      item
    end

    def get_inventory_words
      inv_words = {}
      @inventory.each { |item| inv_words.update(item.class.item_words) }
      inv_words
    end

    def help
      Book.satchel[:help]
    end

    def list_item_names
      item_names = []
      @inventory.each { |item| item_names << item.desc_name }
      item_names
    end

    def room_contains_item(nouns, modifiers)
      taken_item = []
      modifiers.any? do |modifier|
        taken_item << modifier if nouns.include?(modifier)
      end
      taken_item.first unless taken_item.empty?
    end

    def find_item(nouns)
      @inventory.find do |item|
        nouns.include?(item.class.item_name)
      end
    end

    def remove_item(item)
      if item.quantity > 1
        item.decrease_quantity
        return item
      end
      @inventory.delete(item)
    end

    def get_recipe(nouns)
      ingredients = nouns.sort
      result = @recipes.find {|k,v| v == ingredients}
    end


    def item_already_added?(item_name)
      @inventory.find { |item| item.class.item_name == item_name}
    end

    def get_class_from_item_name(item_name)
       Item.items.find { |item_class| item_class.item_name == item_name }
    end
  end
end
