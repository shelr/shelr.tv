steps_for :dashboard do
  use_steps :records
  use_steps :comments

  step "I should see :number comment(s) on dashboard" do |num|
    page.should have_css('.comments .comment', count: num)
  end
end
