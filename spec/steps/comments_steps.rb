steps_for :comments do
  use_steps :records

  step ":record_title record has :number comment(s)" do |title, number|
    number.to_i.times do 
      comment = create(:comment, user: create(:user))
      @_records[title].comments << comment
    end
  end

  step "I should see :number comment(s)" do |num|
    page.should have_css('.comments .comment', count: num)
  end

  step "I should see comment form" do
    page.should have_css('.comment-form form')
    page.should have_css('.comment-form textarea')
    page.should have_css('.comment-form input')
  end

  step "I should not see comment form" do
    page.should_not have_css('.comment-form form')
    page.should_not have_css('.comment-form textarea')
    page.should_not have_css('.comment-form input')
  end

  step "I fill in :something into comment form" do |body|
    within ".comment-form" do
      fill_in 'comment[body]', with: body
    end
  end

  step "I submit comment form" do
    within ".comment-form" do
      click_button 'Submit'
    end
  end

  step "I should see comment with body :body" do |body|
    within ".comments .comment .body" do
      page.should have_content body
    end
  end

  step "record :record has following comments" do |record, table|
    @_comments ||= []
    @_the_record = @_records[record]
    table.hashes.each do |hash|
      comment = @_the_record.comments.build(body: hash['body'])
      comment.user = create(:user, nickname: hash['user'])
      comment.save
    end
    @_comments << @_the_record.reload.comments
  end

  step "I click on the first comment" do
    within ".comments:first-child" do
      find('.body').click
    end
  end
end
