require 't10/story'
module T10
  module CLI
    def self.run
      splash

      scribe T10::Book.storyteller[:intro]

      if T10::Story.ongoing_adventure?
        scribe T10::Book.storyteller[:load_adventure]
        loop do
          scribe T10::Book.storyteller[:load_query], false
          print ">"
          answer = gets.chomp
          if answer == "yes"
            scribe T10::Book.storyteller[:load_query_yes], false
            start_adventure
            break
          elsif answer == "no"
            scribe T10::Book.storyteller[:load_query_no], false
            start_adventure(true)
            break
          else
            scribe T10::Book.storyteller[:load_query_neither]
          end
        end
      else
        start_adventure(true)
      end
    end

    def self.start_adventure(new_adventure = false)
      if new_adventure
        T10::Story.new_adventure
      else
        T10::Story.load_adventure
      end

      if T10::Story.current_room
        scribe T10::Story.current_room.interact([:enter],[],[:game_load])
      end

      while(T10::Story.current_room)
        print "#{T10::Story.current_room.desc_name} "
        print "> "
        T10::Thesaurus.add_words(*T10::Story.current_room.words)
        verbs, nouns, modifiers =  T10::Thesaurus.scan(gets.chomp)

        scribe T10::Story.current_room.interact(verbs, nouns, modifiers)

      end

      the_end unless T10::Story.current_room
    end

    def self.scribe(description, page_splash = true)
      puts '='*38 + '[x]' + '='*39 if page_splash

      description = description.join("\n") if description.is_a? Array
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
