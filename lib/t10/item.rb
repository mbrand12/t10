module T10
  # @abstract This class is a placeholder for concrete item implementations.
  # Item is anything a Hero can pickup in a {Room} and place in the {Satchel},
  # inspect, use and combine with other items in the satchel.
  #
  # Each item has quality and quantity (and the max for both). The quality is
  # increased when the item is combined with another item (for example
  # combining a shiny piece with an amulet will raise the quality of the amulet
  # and remove the shiny piece).
  #
  # Different subclasses will handle the quality differently. For example the
  # {Items::AmuletItem} can only be used to exit the dungeon when the quality
  # is equal to the max_quality etc.
  class Item
    # Holds the list of all the Items that inherit this class.
    @items = []
    class << self
      # @return [Array] list of all classes that inherit {Item}
      attr_reader :items
    end

    # Callback invoked whenever a class inherits the {Room}. Adds the subclass
    # to the @rooms.
    #
    # @return [void]
    def self.inherited(item_implementations)
      @items << item_implementations
    end

    attr_reader :quantity, :quality, :max_quality, :max_quantity

    def initialize
      @inspected = false
    end

    # @return [Symbol] An item keyword.
    def self.item_name; fail NotImplementedError; end

    # @return [Hash] An item keyword as key and synonyms as value.
    def self.item_words; fail NotImplementedError; end

    # Method returns a description which differs weather the item has been
    # inspected before or not.
    #
    # @return [String] item description.
    def desc
      if @inspected
        desc_short
      else
        @inspected = true
        desc_long
      end
    end

    def increase_quantity(quantity = 1)
      return false if @quantity == @max_quantity
      @quantity += quantity
    end

    def decrease_quantity(quantity = 1)
      return false if @quantity == 0 || @quantity < quantity
      @quantity -= quantity
    end

    def increase_quality(quality = 1)
      return false if @quality == @max_quality ||
                      @quality + quality > @max_quality
      @quality += quality
    end

    # @return [String] a short description of an item when it is put in the
    #   satchel
    def desc_put; fail NotImplementedError; end

    # @return [String] a description for the satchel inventory list.
    def desc_name; fail NotImplementedError; end

    # @return [String] a description of the item combining.
    def desc_combined(quality_or_quantity); fail NotImplementedError; end

    protected

    # @return [String] a short description when the satchel inventory is
    #  inspected more than once.
    def desc_short; fail NotImplementedError; end

    # @return [String] a description when the item is inspected for the first
    #   time.
    def desc_long; fail NotImplementedError; end
  end
  require 't10/items/amulet_item'
  require 't10/items/shiny_item'
end
