module T10
  # The class which ensures that everything outputs properly to the console and
  # it also holds the game's main loop.
  module CLI
    # Method is called when user runs `$ ruby bin/t10`
    #
    # The scribe method is made to work similar to puts but with a specific
    # width formating and other fluff.
    #
    # @return [void]
    def self.run
      splash

      scribe Book.storyteller[:intro]

      if Story.ongoing_adventure?(ARGV.include?("--test"))
        scribe Book.storyteller[:load_adventure]
        loop do
          scribe Book.storyteller[:load_query], false
          print ">"
          answer = STDIN.gets.chomp
          if answer == "yes"
            scribe Book.storyteller[:load_query_yes], false
            start_adventure
            break
          elsif answer == "no"
            scribe Book.storyteller[:load_query_no], false
            start_adventure(true)
            break
          else
            scribe Book.storyteller[:load_query_neither]
          end
        end
      else
        start_adventure(true)
      end
    end

    # The method starts the adventure either from the save file or a new
    # adventure.
    #
    # The method makes use of the {Room#words} {Room#interact} interface. The
    # game ends if the hero can't be found in any of the rooms.
    #
    # @param new_adventure [Boolean] if true will trigger a new adventure.
    # @return [void]
    def self.start_adventure(new_adventure = false)
      test_mode = ARGV.include?("--test")
      if new_adventure
        Story.new_adventure(test_mode)
      else
        Story.load_adventure(test_mode)
      end

      if Story.current_room
        scribe Story.current_room.interact([:enter],[],[:game_load])
      end

      while(Story.current_room)
        print "#{Story.current_room.desc_name} "
        print "> "
        Thesaurus.add_words(*Story.current_room.words)
        verbs, nouns, modifiers =  Thesaurus.scan(STDIN.gets.chomp)

        scribe Story.current_room.interact(verbs, nouns, modifiers)

      end

      the_end unless Story.current_room
    end

    private

    def self.scribe(description, page_splash = true)
      puts '='*38 + '[x]' + '='*39 if page_splash

      desc = []
      if description.is_a? Array
        description.flatten.each do |w|
          desc << w.split("\n") unless w.nil?
        end
      else
        desc = description.split("\n")
      end
      description = desc.join("\n~"+" "*78+"~\n")

      if description.length >= 80
        puts format(description)
      else
        puts description
      end
      puts
    end

    def self.format(string, width = 80)
      string.scan(/\S.{0,#{width-2}}\S(?=\s|$)|\S+/)
    end

    def self.splash
      puts ' '*26 + '______________________'
      puts ' '*26 + '\__    ___/_   \   _  \\'
      puts ' '*26 + '  |    |   |   /  /_\  \\'
      puts ' '*26 + '  |    |   |   \  \_/   \\'
      puts ' '*26 + '  |____|   |___|\_____  /'
      puts ' '*26 + '         by mbrand12  \/'
    end

    def self.the_end
      puts ' '*19 + ' _______ _            ______           _'
      puts ' '*19 + '|__   __| |          |  ____|         | |'
      puts ' '*19 + '   | |  | |__   ___  | |__   _ __   __| |'
      puts ' '*19 + '   | |  | \'_ \ / _ \ |  __| | \'_ \ / _` |'
      puts ' '*19 + '   | |  | | | |  __/ | |____| | | | (_| |'
      puts ' '*19 + '   |_|  |_| |_|\___| |______|_| |_|\__,_|'
      puts '='*38 + '[x]' + '='*39
    end
  end
end
