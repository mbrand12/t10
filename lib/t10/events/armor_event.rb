module T10
  module Events
    class ArmorEvent < Event
      VERBS = {
        random: %i(do),
        guard: %i(defend guard defense),
        attack: %i(attack strike),
        deploy: %i(deploy cast),
        check: %i(look glance check)
      }

      NOUNS = {
        something: %i(something),
        box: %i(box control panel vial vials)
      }

      MODIFIERS = {
        horizontal: %i(horizontal horizontally cleave),
        vertical: %i(vertical verticaly),
        thrust: %i(thrust spear),
        kick: %i(kick),
        nanomist: %i(nanomist repair nano mist)
      }

      ACTIONS = {
        attack: %i(horizontal vertical thrust kick),
        guard: %i(horizontal vertical),
        deploy: %i(nanomist)
       }

      def initialize(verbs = nil, nouns = nil, modifiers = nil)
        super

        @complete = false
        @first_random_command = false
        @box_first_time = false

        @armor_hp = 6
        @armor_ap = 5
        @armor_mp = 2
        @armor_sp = 0
        @stone_hp = 10
        @stone_ap = 4

        @prev_stone_action = nil
        @stone_actions = %i(attH attV attT)
      end

      def words
        [VERBS, NOUNS, MODIFIERS]
      end

      def interact(verbs, nouns, modifiers)
        return send(:random, [:something], []) if verbs.empty?
        send(verbs.first, nouns, modifiers)
      end

      def intro
        T10::Book.armor_event[:event_intro]
      end

      def outro
        if @get_back_data[2].include?(:battle_lost)
          ""
        elsif @get_back_data[2].include?(:battle_won)
          T10::Book.armor_event[:battle_aftermath]
        end
      end

      protected

      def random(nouns, modifiers)
        unless nouns.include?(:something)
          return [] << T10::Book.armor_event[:do_nothing]
        end

        verb = ACTIONS.keys.sample
        mods = [ACTIONS[verb].sample]

        desc = []

        com = "#{mods[0].capitalize unless mods[0].nil?} #{verb.capitalize}"

        if @first_random_command
          desc << T10::Book.armor_event[:do_something] % [command: com]
        else
          @first_random_command = true
          desc << T10::Book.armor_event[:do_something_ft] % [command: com]
        end
        desc << send(verb, nil, mods)
      end

      def attack(nouns, modifiers)
        return T10::Book.armor_event[:attack_no_ap] if @armor_ap == 0
        if modifiers.empty? || !ACTIONS[:attack].include?(modifiers.first)
          return T10::Book.armor_event[:attack_nothing]
        end
        desc = []

        armor_attack = ""
        if modifiers.include?(:kick)
          armor_attack = "kick"
        else
          armor_attack = "att#{modifiers[0].to_s[0].upcase}"
        end
        stone_react = stone_action(armor_attack)

        attack_calc(armor_attack, stone_react)

        action = "attack_#{armor_attack}_#{stone_react}"
        desc << T10::Book.armor_event[action.to_sym]

        desc << status_check

        desc
      end

      def guard(nouns, modifiers)
        if modifiers.empty? || !ACTIONS[:guard].include?(modifiers.first)
          return T10::Book.armor_event[:defend_nothing]
        end

        desc = []

        armor_defend = "def#{modifiers[0].to_s[0].upcase}"
        stone_react = stone_action(armor_defend)

        defend_calc(armor_defend, stone_react)

        action = "defend_#{armor_defend}_#{stone_react}"
        action = "defend_def_shield" if stone_react == "shield"

        desc << T10::Book.armor_event[action.to_sym]

        desc << status_check

        desc
      end

      def deploy(nouns, modifiers)
        if @armor_mp < 2
          return T10::Book.armor_event[:deploy_no_mp]
        end

        if modifiers.empty? || !ACTIONS[:deploy].include?(modifiers.first)
          return T10::Book.armor_event[:deploy_nothing]
        end

        desc = []

        armor_deploy = "dep#{modifiers[0].to_s[0].upcase}"
        stone_react = stone_action(armor_deploy)

        deploy_calc(armor_deploy, stone_react)

        action = "deploy_#{armor_deploy}_#{stone_react}"

        desc << T10::Book.armor_event[action.to_sym]

        desc << status_check

        desc
      end

      def check(nouns, modifiers)
        return T10::Book.armor_event[:check_nothing] if nouns.empty?

        if nouns.include?(:box)

          stats = {
            hp: @armor_hp,
            ap: @armor_ap,
            mp: @armor_mp,
            sp: @armor_sp
          }

          if @box_first_time
            T10::Book.armor_event[:check_box] % stats
          else
            @box_first_time = true
            T10::Book.armor_event[:check_box_ft] % stats
          end
        else
          T10::Book.armor_event[:check_nothing]
        end
      end

      def stone_action(armor_action)
        if @stone_ap == 0
         @stone_actions << @prev_stone_action unless @prev_stone_action.nil?
          if armor_action == "attH" || armor_action == "attV" ||
             armor_action == "attT"
            curr_stone_action = armor_action
            @prev_stone_action = curr_stone_action
            @stone_actions.delete(curr_stone_action)
          end
          return "shield"
        end

        curr_stone_action = @stone_actions.sample
        @stone_actions << @prev_stone_action unless @prev_stone_action.nil?
        @prev_stone_action = curr_stone_action
        @stone_actions.delete(curr_stone_action)
        return "att" if armor_action == "kick" || armor_action == "depN"
        curr_stone_action.to_s
      end

      def attack_calc(armor_action, stone_action)
        if armor_action == "attH"
          if stone_action == "attH"
            @armor_ap -= 1
            @stone_hp -= 1
            @stone_ap -= 1
          elsif stone_action == "attV"
            @armor_hp -= 1
            @armor_sp += 1
            @armor_ap -= 1
            @stone_hp -= 1
            @stone_ap -= 1
          elsif stone_action == "attT"
            @armor_hp -= 1
            @armor_sp += 1
            @armor_ap -= 1
            @stone_ap -= 1
          elsif stone_action == "shield"
            @armor_hp -= 2
            @armor_sp += 2
            @armor_ap -= 1
            @stone_ap += 3
          end
        elsif armor_action == "attV"
          if stone_action == "attH"
            @armor_hp -= 1
            @armor_sp += 1
            @armor_ap -= 1
            @stone_hp -= 1
            @stone_ap -= 1
          elsif stone_action == "attV"
            @armor_hp -= 1
            @armor_sp += 1
            @armor_ap -= 1
            @stone_ap -= 1
          elsif stone_action == "attT"
            @armor_hp -= 1
            @armor_sp += 1
            @armor_ap -= 1
            @stone_ap -= 1
          elsif stone_action == "shield"
            @armor_hp -= 2
            @armor_sp += 2
            @armor_ap -= 1
            @stone_ap += 3
          end
        elsif armor_action == "attT"
          if stone_action == "attH"
            @armor_hp -= 1
            @armor_sp += 1
            @armor_ap -= 1
            @stone_ap -= 1
          elsif stone_action == "attV"
            @armor_hp -= 1
            @armor_sp += 1
            @armor_ap -= 1
            @stone_ap -= 1
          elsif stone_action == "attT"
            @armor_ap -= 1
            @stone_hp -= 2
            @stone_ap -= 1
          elsif stone_action == "shield"
            @armor_hp -= 2
            @armor_sp += 2
            @armor_ap -= 1
            @stone_ap += 3
          end
        elsif armor_action == "kick"
          if stone_action == "shield"
            @armor_ap -= 1
            @stone_hp -= 2
            @stone_ap += 1
          else
            @armor_hp -= 1
            @armor_sp += 1
            @armor_ap -= 1
            @stone_ap -= 1
          end
        end
      end

      def defend_calc(armor_action, stone_action)
        if armor_action == "defH"
          if stone_action == "attH"
            @armor_hp -= 1
            @armor_sp += 1
            @armor_ap += 2
            @stone_ap -= 1
          elsif stone_action == "attV"
            @armor_ap += 3
            @stone_hp -= 2
            @stone_ap -= 1
          elsif stone_action == "attT"
            @armor_hp -= 1
            @armor_sp += 1
            @armor_ap += 2
            @stone_ap -= 1
          elsif stone_action == "shield"
            @armor_ap += 3
            @stone_ap += 3
          end
        elsif armor_action == "defV"
          if stone_action == "attH"
            @armor_sp += 3
            @stone_hp -= 2
            @stone_ap -= 1
          elsif stone_action == "attV"
            @armor_hp -= 1
            @armor_sp += 1
            @armor_ap += 2
            @stone_ap -= 1
          elsif stone_action == "attT"
            @armor_hp -= 1
            @armor_sp += 1
            @armor_ap += 2
            @stone_ap -= 1
          elsif stone_action == "shield"
            @armor_ap += 3
            @stone_ap += 3
          end
        end
      end

      def deploy_calc(armor_action, stone_action)
        if armor_action == "depN"
          if stone_action == "shield"
            @armor_hp += 3
            @armor_ap += 2
            @armor_mp -= 2
            @stone_hp += 1
            @stone_ap += 3
          else
            @armor_hp += 3
            @armor_ap += 2
            @armor_mp -= 2
            @stone_ap -= 1
          end
        end
      end

      def status_check
        if @armor_hp <= 0
          @get_back_data[2] = [:battle_lost]
          @complete = true
          return T10::Book.armor_event[:battle_lost]
        end

        if @stone_hp <= 0
          @get_back_data[2] = [:battle_won]
          @complete = true
          return T10::Book.armor_event[:battle_won]
        end

        if @stone_ap == 0
          return T10::Book.armor_event[:stone_no_ap]
        end
      end
    end
  end
end
