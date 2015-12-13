# @announce
Feature: Save/Load Game
  In order to continue playing the game later.
  As a user.
  I should be able to save and load the game.

  Scenario: Answering "yes" to the save game prompt
    Given I run `ruby ../../bin/t10 --test` interactively
    And I type "no"
    And I type "enter gate"
    And I type "exit back"
    When I type "yes"
    When I close the stdin stream
    Then the output should contain:
    """
    remember
    """
    And a file named "../../test/data/aruba_game.yml" should contain:
    """
    EntranceRoom
    """

  Scenario: Answering "yes" to the load game prompt
    Given I run `ruby ../../bin/t10 --test` interactively
    When I type "yes"
    And I close the stdin stream
    Then the output should contain:
    """
    Ah, yes. I remmember...
    """
