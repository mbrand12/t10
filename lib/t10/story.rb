require 'yaml'
require 't10/dungeon'

module T10
  class Story

    @save_path = File.expand_path('../../../data/game.yml', __FILE__)
    @dungeon = nil

    def self.new_adventure
      check_save_file

      #TODO: any point to here being crated here instead of entrance room?
      hero = Hero.new
      @dungeon = Dungeon.generate
      @dungeon.first.hero = hero

      data = {
        dungeon: []
      }
      File.open(@save_path, 'w') {|f| YAML.dump(data, f)}
    end

    def self.save_adventure
      check_save_file

      data = {
        dungeon: @dungeon
      }
      File.open(@save_path, 'w') {|f| YAML.dump(data, f)}
    end

    def self.load_adventure
      check_save_file
      data = YAML.load_file(@save_path)
      @dungeon = data[:dungeon]
    end

    def self.current_room
      @dungeon.find { |room| room.hero_here?}
    end

    def self.ongoing_adventure?
      check_save_file
      data = YAML.load_file(@save_path)
      return false unless data.is_a?(Hash)
      data.key?(:dungeon) && data[:dungeon].any? && data[:dungeon].size == 12
    end

    private

    def self.check_save_file
      fail RuntimeError, "Save file not found" unless File.exist?(@save_path)
    end
  end
end

