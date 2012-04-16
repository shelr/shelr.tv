require 'spec_helper'

describe User do

  subject { build :user }

  it_behaves_like "editable with restrictions"
  it_behaves_like "editable by God"
  it_behaves_like "editable by Owner"

  its(:owner) { should_not be_blank }

  describe "on create" do
    it "should generate api key" do
      subject.should_receive(:generate_api_key!)
      subject.save
    end

    it "should be renamed if nickname blank" do
      subject.should_receive(:maybe_assign_nickname_placeholder)
      subject.save
    end
  end

  describe "#maybe_assign_nickname_placeholder" do
    it "should change blank nickname to 'noname'" do
      subject.nickname = ''
      subject.save.should be_true
      subject.nickname.should == 'noname'
    end
  end

  describe "#generate_api_key" do
    it "should assign random md5 hash to #api_key" do
      subject.api_key.should be_blank
      subject.generate_api_key
      subject.api_key.should_not be_blank
    end
  end

  describe "#generate_api_key!" do
    before(:each) { subject.save }

    it "should call generate_api_key" do
      subject.should_receive :generate_api_key
      subject.generate_api_key!
    end

    it "should save the record" do
      subject.should_receive :save
      subject.generate_api_key!
    end
  end

  describe "#comments_for_records" do
    it "should return comments for record" do
      commentable = create(:record, user: subject)
      commentable.comments << create(:comment)
      Comment.for('record', commentable.id).should == subject.comments_for_records
    end

    it "should return comments for all records" do
      comments = []

      2.times do
        commentable = create(:record, user: subject)
        commentable.comments << create(:comment)
        comments += Comment.for('record', commentable.id)
      end

      comments.each { |comment|  subject.comments_for_records.should include(comment) }
    end

    it "should return comment in reversed order" do
      comments = []

      2.times do |i|
        commentable = create(:record, user: subject)
        comment = create(:comment)
        comment.updated_at = Time.now + i * 100
        commentable.comments << comment
        comments += Comment.for('record', commentable.id)
      end

      comments.reverse.should == subject.comments_for_records
    end

    it "should add methods to array for kaminari" do
      commentable = create(:record, user: subject)
      commentable.comments << create(:comment)
      comments = subject.comments_for_records
      comments.should respond_to(:current_page)
    end
  end
end
