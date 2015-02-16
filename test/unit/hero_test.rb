require 'test_helper'

class HeroTest < Minitest::Test
  def setup
    @hero = T10::Hero.new
  end

  def teardown
    @hero = nil
  end

  def test_initial_hit_points
    assert_equal T10::Hero::MAX_HP, @hero.hit_points,
      "Hero should have #{T10::Hero::MAX_HP} hit points"
  end

  def test_takes_a_hit
    @hero.damage(1)
    remaining_hp = T10::Hero::MAX_HP - 1
    assert_equal remaining_hp, @hero.hit_points,
      "Hero should have #{remaining_hp} hit points remaining"\
      " after being damaged with 1 damage"
  end

  def test_killed
    @hero.damage(T10::Hero::MAX_HP)
    assert_equal true, @hero.dead,
      "Hero should die if dealt #{T10::Hero::MAX_HP} or more damage"
  end

  def test_restores_hp
    @hero.damage(2)
    @hero.heal(1)
    remaining_hp = T10::Hero::MAX_HP - 1
    assert_equal remaining_hp, @hero.hit_points,
      "Hero's hit points should be restored to #{remaining_hp} HP"
  end

  def test_hp_restoration_limit
    @hero.damage(2)
    @hero.heal(T10::Hero::MAX_HP)
    assert_equal T10::Hero::MAX_HP, @hero.hit_points,
      "Hero should not be able to restore to more than " \
      "#{T10::Hero::MAX_HP} hit points"
  end
end
