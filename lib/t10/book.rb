require 'yaml'

module T10
  # This class reads the descriptions from the .yml file. This makes it so that
  # the text and logic won't mix since it would make the already bloated
  # classes even worse and because .yml is ideal for writing the descriptions.
  #
  # The class relies on {Book.method_missing} to find the needed description
  # and provided that the file name follows certain rules or conventions:
  #
  # - The name of the file must be the name of the class (down cased).
  # - If the class is a child of a class that also uses {Book} for descriptions
  #   it must end with the parent's class name and be located in the folder named
  #   after the parent's class name.
  # - If used within a "verb method" (see {Room} for clarification) the symbol
  #   to access the specific description should begin with that verb.
  #
  # Examples:
  #
  #     Book.armor_room[:look_armor]
  #     Book.simple_room[:touch_inkwell]
  #
  class Book
    # @param symbol [Symbol] the name of the class method corresponding with the
    #   name of the file.
    # @return [String] the description.
    def self.method_missing(symbol)
      str = symbol.to_s
      if symbol == :room || symbol == :storyteller || symbol == :satchel
        get_text("@#{symbol}", "../../../data/#{symbol}.yml")
      elsif str =~ /^.*_room/ || str =~ /^.*_event/ || str =~ /^.*_item/
        dir = str.split("_").last
        get_text("@#{symbol}", "../../../data/#{dir}s/#{symbol}.yml")
      else
        super
      end
    end

    private

    def self.get_text(variable, path)
      path = File.expand_path(path, __FILE__)
      fail RuntimeError, "Text File not found" unless File.exist?(path)
      unless instance_variable_defined? variable
       instance_variable_set(variable, YAML.load_file(path))
      end
      instance_variable_get variable
    end
  end
end
