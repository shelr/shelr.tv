require 'spec_helper'

describe HomeController do
  describe "GET about" do
    it "should render about page" do
      get :about
      response.should render_template('home/about')
    end
  end

  describe "GET landing" do
    it "should assign records for feed" do
      create :record
      get :landing
      assigns(:records).should_not be_blank
    end
  end

  describe 'GET dashboard' do
    let(:user) { build(:user) }

    context 'when format is html' do
      before { subject.stub(:current_user).and_return(user) }

      it 'should fetch all comments' do
        comments = []
        user.should_receive(:comments_for_records).and_return(comments)
        get :dashboard
      end

      it 'should paginate comments' do
        comments = []
        paginated_comments = []
        paginated_comments.stub_chain(:page, :per)
        user.should_receive(:comments_for_records).and_return(comments)
        Kaminari.should_receive(:paginate_array).with(comments).and_return(paginated_comments)
        get :dashboard
      end
    end

    context 'when format is atom' do
      it 'should render blank body if no key is specified' do
        get :dashboard, format: 'atom'
        response.body.should be_blank
      end

      it 'should render blank body if no user with specified key' do
        get :dashboard, format: 'atom', key: 'some_non_existing_key'
        response.body.should be_blank
      end

      it 'should assign comments for user' do
        record = create(:record, user: user)
        2.times { create(:comment, commentable: record) }
        get :dashboard, format: 'atom', key: user.atom_key
        assigns(:comments).should have(2).item
      end

      it 'should assign user' do
        get :dashboard, format: 'atom', key: user.atom_key
        assigns(:user).should eql(user)
      end
    end
  end
end
