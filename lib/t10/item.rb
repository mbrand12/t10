module T10
  class Item

    @items = []
    class << self
      attr_reader :items
    end

    def self.inherited(item_implementations)
      @items << item_implementations
    end

    attr_reader :quantity, :quality, :max_quality, :max_quantity

    def initialize
      @inspected = false
      @combined = false
    end

    def self.item_name; fail NotImplementedError; end
    def self.item_words; fail NotImplementedError; end

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

    protected

    def desc_put; fail NotImplementedError; end
    def desc_short; fail NotImplementedError; end
    def desc_long; fail NotImplementedError; end
    def desc_name; fail NotImplementedError; end
    def desc_combined(quality_or_quantity); fail NotImplementedError; end
  end
  require 't10/items/amulet_item'
  require 't10/items/shiny_item'
end
