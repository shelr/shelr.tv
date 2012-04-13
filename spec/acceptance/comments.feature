@javascript
Feature: Comments
  As a Ŝelr user
  I would like to comment records
  In order to share my point of view

  Background:
    Given there are following records
      | title         | fixture | user     |
      | hello world   | ls.json | antono   |
      | goodbye world | ls.json | ntanyone |
      | shelr manual  | ls.json | antono   |

  Scenario: browsing comments
    Given "hello world" record has 3 comments
    When I visit "/records" page
    And I click link "hello world"
    Then I should see 3 comments

  Scenario: not logged in user wants to submit comment
    Given "hello world" record has 3 comments
    When I visit "/records" page
    And I click link "hello world"
    Then I should not see comment form
