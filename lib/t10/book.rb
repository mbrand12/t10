require 'yaml'

module T10
  class Book
    def self.method_missing(symbol)
      if symbol == :room
        get_text("@#{symbol}", "../../../data/#{symbol}.yml")
      elsif symbol == :storyteller
        get_text("@#{symbol}", "../../../data/#{symbol}.yml")
      elsif symbol.to_s =~ /^.*_room/
        get_text("@#{symbol}", "../../../data/rooms/#{symbol}.yml")
      elsif symbol.to_s =~ /^.*_event/
        get_text("@#{symbol}", "../../../data/events/#{symbol}.yml")
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
