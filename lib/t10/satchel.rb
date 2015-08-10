require 't10/item'
module T10
  class Satchel

    VERBS = {
      inspect: %i(inspect)
    }

    NOUNS = {}

    MODIFIERS = {}

    def initialize
      @inventory = []
      add_item(T10::Items::AmuletItem.item_name)
    end

    def interact(verbs, nouns, modifiers)
      return help if verbs.empty?
      send(verbs[0], nouns, modifiers)
    end

    def words
      [VERBS, NOUNS.merge(get_inventory_words), MODIFIERS]
    end

    protected

    def add_item(item_name)
      if item = item_added?(item_name)
        return item.increase_quantity
      end

      item_class = get_class_from_item_name(item_name)
      @inventory << item_class.new
      NOUNS.update(item_class.item_words)
    end

    def item_added?(item_name)
      @inventory.find { |item| item.class.item_name == item_name}
    end

    def get_class_from_item_name(item_name)
       Item.items.find {|item_class| item_class.item_name == item_name}
    end

    def help
      T10::Book.satchel[:help]
    end

    def inspect(nouns, modifiers)
      desc = []
      if nouns.empty?
        desc <<  T10::Book.satchel[:inspect_blank] << list_item_names
      elsif item = find_item(nouns)
        desc << item.desc
      end
    end

    def combine(nouns, modifiers)
      # TODO there can be more than one shiny peace in the inventory
      if nouns.include?(AmuletItem.item_name) && nouns.include?()

      end
    end

    def use

    end

    def put

    end


    private

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
