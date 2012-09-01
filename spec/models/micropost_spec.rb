require 'spec_helper'

describe Micropost do
  
  let(:user) { FactoryGirl.create(:user) }
  before do
  	@micropost = user.microposts.build(content:  "Lorem ipsum")
  end

  subject { @micropost }

  it { should respond_to(:content) }
  it { should respond_to(:user_id) }
  it { should respond_to(:user) }
  it { should respond_to(:in_reply_to) }
  it { should respond_to(:in_reply_length) }
  its(:user) { should == user }

  it { should be_valid }

  describe "when user_id is not present" do
  	before { @micropost.user_id = nil }
  	it { should_not be_valid }
  end

  describe "with blank content" do
    before { @micropost.content = " " }
    it { should_not be_valid }
  end

  describe "accesible attributes" do
  	it "should not allow access to user_id" do
  		expect do
  			Micropost.new(user_id: user.id)
  		end.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
  	end
  end

  describe "replies" do
    before(:each) do
      @reply_to_user = FactoryGirl.create(:userToReplyTo)
      @micropost = user.microposts.create(content: "@User_To_Reply look a reply to User To Reply")
    end
    it "should identify a @user and set the in_reply_to field accordingly" do
      @micropost.in_reply_to.should ==  @reply_to_user
    end
  end

  
end
