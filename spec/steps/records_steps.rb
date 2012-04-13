steps_for :records do

  step "I should see :some records" do |some|
    case some
    when 'some'
      page.find('.records .record').should_not raise_error Capybara::ElementNotFound
    when '0'
      page.find('.records .record').should raise_error Capybara::ElementNotFound
    else
      page.find('.records .record').should_not raise_error Capybara::ElementNotFound
      page.find('.records .record').count.should == Integer(some)
    end
  end

  step "I should see player for :record_title" do |title|
    within '#player' do
      page.should have_content title
      page.should have_css '#term'
      page.should have_css 'nav.controls'
    end
  end

  step "I should not see player for :record_title" do |title|
    page.should_not have_css '#player'
    page.should_not have_content title
  end

  step "there is/are :num record(s) in db" do |num|
    num = Integer(num)
    case num
    when 0
      Record.destroy_all
    else
      (num - Record.count).times do
        create(:record)
      end
    end
  end

  step "there are following records" do |table|
    @_records = {}
    table.hashes.each do |hash|
      record_json = load_record('ls.json')
      record_json.delete('created_at')
      record = build(:record, record_json)
      record.title = hash['title']
      record.user = create(:user, nickname: hash['nickname'])
      record.save
      @_records[hash['title']] = record
    end
  end

  step "record :title is private" do |title|
    @_records[title].private = true
    @_records[title].save
  end

  step "I visit :title record page" do |title|
    visit record_path @_records[title]
  end

  step "I visit :title record page with access key" do |title|
    visit record_path @_records[title], access_key: @_records[title].access_key
  end

  step "I am the owner of :title record" do |title|
    @_records[title].user = User.where(email: 'self@antono.info').first
    @_records[title].save
  end
end
