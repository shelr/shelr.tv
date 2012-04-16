require 'spec_helper'

describe UserDecorator do
  before { ApplicationController.new.set_current_view_context }

  context '#avatar_url' do
    let(:user) { mock_model(User, :nickname => 'nash') }

    it "has anonymous user" do
      user.stub(:nickname) { 'Anonymous' }
      described_class.decorate(user).avatar_url(10).should == '/assets/avatars/anonymous-10.png'
    end

    it "has blank email" do
      user.stub(:email) { '' }
      described_class.decorate(user).avatar_url(10).should == '/assets/avatars/default-10.png'
    end

    it "has some email" do
      user.stub(:email) { 'zomg@example.com' }
      digest = Digest::MD5.hexdigest(user.email)

      described_class.decorate(user).avatar_url(10).should == "http://www.gravatar.com/avatar/#{digest}?s=10"
    end
  end
end
