require 't10/item'
module T10
  class Satchel

    VERBS = {
      inspect: %i(inspect),
      put: %i(put place pick),
      use: %i(use),
      combine: %i(combine)
    }

    NOUNS = {}

    MODIFIERS = {}

    def initialize
      @inventory = []
      add_item(T10::Items::AmuletItem.item_name)

      @recipes = {
        T10::Items::AmuletItem.item_name =>
           [
             T10::Items::AmuletItem.item_name,
             T10::Items::ShinyItem.item_name
           ].sort
      }
    end

    def interact(verbs, nouns, modifiers)
      return help if verbs.empty?
      send(verbs[0], nouns, modifiers)
    end

    def words
      [VERBS, NOUNS.merge(get_inventory_words), MODIFIERS]
    end

    protected

    def help
      [] << T10::Book.satchel[:help]
    end

    def inspect(nouns, modifiers)
      desc = []
      if nouns.empty?
        desc <<  T10::Book.satchel[:inspect_blank] << list_item_names
      elsif item = find_item(nouns)
        desc << item.desc
      end
    end

    def put(nouns, modifiers)
       return [] << T10::Book.satchel[:put_blank] if nouns.empty?

       if nouns.include?(modifiers[0]) && item = add_item(nouns[0])
         desc = T10::Book.satchel[:put_item] % [item_name: item.desc_name]
         [] << desc << modifiers[0]
       else
         [] << T10::Book.satchel[:put_already]
       end
    end

    def use(nouns, modifiers)
      return [] << T10::Book.satchel[:use_cant_there] if modifiers.include?(:no_use)
      return [] << T10::Book.satchel[:use_no_item] if modifiers.include?(:no_item_to_use)
      return [] << T10::Book.satchel[:use_blank] if nouns.empty?

      if nouns.include?(modifiers[0]) && item = find_item(nouns)
        if item.quality == item.max_quality || true  # TODO: R E M O V E WHEN YOU DEV ALL THE ROOMS!
          remove_item(item)
          desc = T10::Book.satchel[:use_item] % [item_name: item.desc_name]
          [] << desc << modifiers[0]
        else
          [] << T10::Book.satchel[:use_cant_yet]
        end
      else
        [] << T10::Book.satchel[:use_already]
      end
    end

    def combine(nouns, modifiers)
      inv_words = get_inventory_words.keys
      nouns.delete_if {|noun| !inv_words.include?(noun)}

      return [] << T10::Book.satchel[:combine_not_enough] if nouns.length < 2
      return [] << T10::Book.satchel[:combine_too_many] if nouns.length > 2

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
          [] << result_item.desc_combined(new_q_or_q)
        else
          item = add_item(recipe_hash[0])
          [] <<  T10::Book.satchel[:combine_new] % [item_name: item.desc_name]
        end
      end
    end

    private

    def get_recipe(nouns)
      ingredients = nouns.sort
      result = @recipes.find {|k,v| v == ingredients}
    end

    def add_item(item_name)
      if item = item_already_added?(item_name)
        item.increase_quantity
        return item
      end

      item_class = get_class_from_item_name(item_name)
      item = item_class.new
      @inventory << item
      item
    end

    def remove_item(item)
      if item.quantity > 1
        item.decrease_quantity
        return item
      end

      @inventory.delete(item)
    end

    def item_already_added?(item_name)
      @inventory.find { |item| item.class.item_name == item_name}
    end

    def get_class_from_item_name(item_name)
       Item.items.find {|item_class| item_class.item_name == item_name}
    end

    def list_item_names
      item_names = []
      @inventory.each { |item| item_names << item.desc_name}
      item_names
    end

    def get_inventory_words
      inv_words = {}
      @inventory.each {|item| inv_words.update(item.class.item_words) }
      inv_words
    end

    def find_item(nouns)
      @inventory.find do |item|
        nouns.include?(item.class.item_name)
      end
    end
  end
end