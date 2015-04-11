require 't10/satchel'

module T10
  class Hero
    MAX_HP = 3

    attr_reader :hit_points
    attr_reader :dead
    attr_reader :satchel

    alias_method :dead?, :dead

    def initialize
      @hit_points = MAX_HP
      @dead = false
      @luck = 10
      @satchel = nil
    end

    def damage(dmg)
      if @hit_points - dmg < 1
        @dead = true
        @hit_points = 0
      else
        @hit_points -= dmg
      end
    end

    def heal(hp)
      if hp + @hit_points > 3
        @hit_points = 3
      else
        @hit_points += hp
      end
    end

    def chance_heal(hp)
      if rand(100) < @luck
        heal(hp)
      end
    end

    def at_full_health?
      @hit_points == MAX_HP
    end

    def obtain_satchel
      @satchel = Satchel.new
    end
  end
end
