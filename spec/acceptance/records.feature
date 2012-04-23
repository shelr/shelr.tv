@javascript

Feature: Records
  As a Ŝelr user
  I would like to browse and publish records
  In order to know something new or impress my friends

  Background:
    Given there are following records
      | title          | fixture | user     |
      | hello world    | ls.json | antono   |
      | goodbye world  | ls.json | ntanyone |
      | shelr manual   | ls.json | antono   |
      | private record | ls.json | someone  |
    And I signed in

  Scenario: browsing records
    When I visit "/records" page
    And I click link "hello world"
    Then I should see player for "hello world"
    When I visit "/records" page
    And I click link "goodbye world"
    Then I should see player for "goodbye world"

  Scenario: private records are hidden
    Given record "private record" is private
    And I am not owner of "private record" record
    When I visit "/records" page
    Then I should not see "private record"
    When I visit "/" page
    Then I should not see "private record"
    When I visit profile of "private record" owner
    Then I should not see "private record"

  Scenario: visiting private records without access key
    Given record "private record" is private
    When I visit "private record" record page
    Then I should not see "private record"
    And I should see "No such record"

  Scenario: visiting private record with access key
    Given record "hello world" is private
    When I visit "hello world" record page with access key
    Then I should see "hello world"
    And I should see player for "hello world"
    And I should not see "No such record"

  Scenario: owner always can see his private records
    Given record "shelr manual" is private
    And I am the owner of "shelr manual" record
    When I visit "/records" page
    Then I should see "shelr manual"
    When I visit "shelr manual" record page
    Then I should see player for "shelr manual"

  Scenario: owner can edit own record
    Given I am the owner of "shelr manual" record
    When I change "shelr manual" record title to "new shelr manual"
    Then I should see "Record was succesfully updated."
