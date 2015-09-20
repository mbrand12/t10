module T10
  # The Hero class is used to hold stats about the hero as well as the
  # reference to the {Satchel}. The object of the class is also used as a
  # pointer to the current room occupied by the hero.
  class Hero
    # Maximum Hit points that a hero can have.
    MAX_HP = 3

    # @return [Integer] hero's current hit points.
    attr_reader :hit_points

    # @return [Boolean] true if hero has no hit points left.
    attr_reader :dead

    # @return [Satchel]
    attr_reader :satchel

    alias_method :dead?, :dead


    def initialize
      @hit_points = MAX_HP
      @dead = false
      @luck = 10
      @satchel = nil
    end

    # @param dmg [Integer] the number of hit points to decrease.
    # @return [Integer] hit points left.
    def damage(dmg)
      if @hit_points - dmg < 1
        @dead = true
        @hit_points = 0
      else
        @hit_points -= dmg
      end
    end

    # @param hp [Integer] the number of hit points to increase
    # @return [Integer] hit points left.
    def heal(hp)
      if hp + @hit_points > 3
        @hit_points = 3
      else
        @hit_points += hp
      end
    end

    # A chance to heal hero, used mostly when passing trough the hallways while
    # damaged.
    #
    # @param hp [Integer] the number of hit points to increase.
    # @return [Integer, nil] the number of hit points left or nil.
    def chance_heal(hp)
      if rand(100) < @luck
        heal(hp)
      end
    end

    # @return [Boolean] true if the hero has max hp.
    def at_full_health?
      @hit_points == MAX_HP
    end

    # Creates new instance of satchel
    # @return [Satchel]
    def obtain_satchel
      @satchel = Satchel.new
    end
  end
end
