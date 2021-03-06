# == Schema Information
#
# Table name: users
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

require 'spec_helper'

describe User do

  before do 
  	@user = User.new(name: "Example User", email: "user@example.com", password: "foobar", password_confirmation: "foobar")
  end

  subject { @user }
  
  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:admin) }
  it { should respond_to(:authenticate) }
  it { should respond_to(:microposts) }
  it { should respond_to(:feed) }
  it { should respond_to(:relationships) }
  it { should respond_to(:followed_users) }
  it { should respond_to(:following?) }
  it { should respond_to(:follow!) }
  it { should be_valid }
  it { should_not be_admin }

  describe "with admin attribute set to 'true'" do
    before do
      @user.save!
      @user.toggle!(:admin)
    end

    it { should be_admin }
  end

  describe "accesible attributes" do
    it "should not allow access to admin attribute" do
      expect do
        User.new(name: "Example User", email: "user@example.com", password: "foobar", password_confirmation: "foobar", admin: true)
      end.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end



  describe "when name is not present" do
  	before { @user.name = " " }
  	it { should_not be_valid }
  end

  describe "when email is not present" do
  	before { @user.email = " " }
  	it { should_not be_valid }
  end

  describe "when name is too long" do
  	before { @user.name = "a" * 51 }
  	it { should_not be_valid }
  end

  describe "when email format is invalid" do
  	it "should be invalid" do
  		addresses = %w[user@foo,com user_at_foo.org example.user@foo foo@bar_baz.com foo@bar+baz.com]
  		addresses.each do |invalid_address|
  			@user.email = invalid_address
  			@user.should_not be_valid
  		end
  	end
  end

  describe "when email format is valid" do
  	it "should be valid" do
  		addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
  		addresses.each do |valid_address|
  			@user.email = valid_address
  			@user.should be_valid
  		end
  	end
  end

  describe "when email address is already taken" do
  	before do
  		user_with_same_email = @user.dup
  		user_with_same_email.save
  	end 

  	it { should_not be_valid }
  end

  describe "when password is not present" do
  	before { @user.password = @user.password_confirmation = " "}
  	it { should_not be_valid}
  end

  describe "when password doesn't match confirmation" do
  	before { @user.password_confirmation = "mismatch"}
  	it { should_not be_valid}
  end

  describe "when password_confirmation is nil" do
  	before { @user.password_confirmation = nil }
  	it { should_not be_valid}
  end

  describe "return value of authenticate method" do
  	before { @user.save }
  	let(:found_user) { User.find_by_email(@user.email) }

  	describe "with valid password" do
  		it { should == found_user.authenticate(@user.password) }
  	end

  	describe "with invalid password" do
  		let (:user_for_invalid_password) { found_user.authenticate("invalid") }

  		it { should_not == user_for_invalid_password }
  		specify { user_for_invalid_password.should be_false }
  	end
  end

  describe "with a password that's too short" do
    before { @user.password = @user.password_confirmation = "a" * 5 }
    it { should be_invalid }
  end

  describe "email address with mixed case" do
    let(:mixed_case_email) { "Foo@ExAMPle.CoM" }
    it "should be saved as all lower-case" do
      @user.email = mixed_case_email
      @user.save
      @user.reload.email.should == mixed_case_email.downcase
    end
  end

  describe "remember token" do
    before { @user.save }
    its(:remember_token) { should_not be_blank }
  end

  describe "micropost associations" do
    
    before { @user.save }
    let!(:older_micropost) do
      FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago)
    end
    let!(:newer_micropost) do
      FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago)
    end

    it "should have the right microposts in the right order" do
      @user.microposts.should == [newer_micropost, older_micropost]
    end

    it "should destroy associated microposts" do
      microposts = @user.microposts
      @user.destroy
      microposts.each do |micropost|
        lambda do
          Micropost.find(micropost.id)
        end.should raise_error(ActiveRecord::RecordNotFound)
        Micropost.find_by_id(micropost.id).should be_nil
      end
    end

    describe "status" do
      let(:unfollowed_post) do
        FactoryGirl.create(:micropost, user: FactoryGirl.create(:user))
      end
      let(:followed_user) { FactoryGirl.create(:user) }

      before do
        @user.follow!(followed_user)
        3.times { followed_user.microposts.create!(content: "Lorem ipsum") }
      end

      its(:feed) { should include(newer_micropost) }
      its(:feed) { should include(older_micropost) }
      its(:feed) { should_not include(unfollowed_post) }
      its(:feed) do
        followed_user.microposts.each do |micropost|
          should include(micropost)
        end
      end
    end
  end

  describe "following" do
    let(:other_user) { FactoryGirl.create(:user) }
    let(:another_user) { FactoryGirl.create(:user) }

    before do
      @user.save
      @user.follow!(other_user)
      @user.follow!(another_user)
    end

    it { should be_following(other_user) }
    it { should be_following(another_user) }
    its(:followed_users) { should include(other_user) }
    its(:followed_users) { should include(another_user) }

    describe "followed user" do
      subject { other_user }
      its(:followers) { should include(@user) }
    end

    describe "followed another user" do
      subject { another_user }
      its(:followers) { should include(@user) }
    end
  end

  describe "relationships associations" do
    let(:other_user) { FactoryGirl.create(:user) }
    before do
      @user.save
      @user.follow!(other_user)
      other_user.follow!(@user)
    end

    it "should destroy associated relationships" do
      relationships = @user.relationships
      @user.destroy
      relationships.should be_empty
    end

    it "should destroy associated reverse relationships" do
      reverse_relationships = @user.reverse_relationships
      @user.destroy
      reverse_relationships.should be_empty
    end

    context "when a follower/followed user is destroyed" do
      subject { other_user }

      before { @user.destroy }

      its(:relationships) { should_not include(@user) }
      its(:reverse_relationships) { should_not include(@user) }
      its(:followed_users) { should_not include(@user) }
      its(:followers) { should_not include(@user) }
    end
  end

  describe "user relationships associations" do
    let (:other_user) { FactoryGirl.create(:user) }
    let (:another_user) { FactoryGirl.create(:user) }
    let (:user_relationships) { @user.relationships }
    let (:user_reverse_relationships) { @user.reverse_relationships }

    before do
      @user.save
      @user.follow!(other_user)
      @user.follow!(another_user)
      other_user.follow!(@user)
      other_user.follow!(another_user)
      another_user.follow!(@user)
      another_user.follow!(other_user)
      user_relationships = @user.relationships
      user_reverse_relationships = @user.reverse_relationships
      user_followings = @user.followed_users
      other_user_followers = other_user.followers
    end

    its(:followed_users) { should include(other_user) }
    its(:followers) { should include(another_user) }
    its(:relationships) { should_not be_empty }
    its(:reverse_relationships) { should_not be_empty }

    describe "should disappear from followers" do
      
      before do 
        @user.destroy
      end

      
      it "user relationships should be nil" do
        user_relationships.should be_empty
      end
      it "user reverse relationships shoulb be empty" do
        user_reverse_relationships.should be_empty
      end
      

      subject { other_user }
      its(:followed_users) { should_not include(@user) }
      its(:followers) { should_not include(@user) }
      its(:relationships) { should_not include(@user) }
      its(:reverse_relationships) { should_not include(@user) }

      subject { another_user }
      its(:followed_users) { should_not include(@user) }
      its(:followers) { should_not include(@user) }
      its(:relationships) { should_not include(@user) }
      its(:reverse_relationships) { should_not include(@user) }
    end

    it "should destroy associated followers" do
      followers = @user.followers
      @user.destroy
      followers.each do |follower|
        follower.followed_users.should_not include(@user)
      end
    end

    it "should destroy associated followed users" do
      followed_users = @user.followed_users
      @user.destroy
      followed_users.each do |followed_user|
        followed_user.followers.should_not include(@user)
      end
    end
  end

  describe "user replies" do
    before(:each) do
      @reply_to_user = FactoryGirl.create(:userToReplyTo)
      @user_with_strange_name = FactoryGirl.create(:user, email: "strange_name@example.com", name: "Duck Van Quack")
    end
    it "should provide a Shorhand Username" do
      @reply_to_user.shorthand.should == "User_To_Reply"
    end
    it "should provide a Shorthand Username for names with 3 parts" do
      @user_with_strange_name.shorthand.should == "Duck_Van_Quack"
    end
    it "should be findable by shorthand name" do
      user = User.find_by_shorthand("User To Reply")
      user.should == @reply_to_user
    end
    it "should scope replies to self" do 
      @user.save!
      m = @user.microposts.create(content:"@User_To_Reply to user")
      m.in_reply_to.should == @reply_to_user
      @reply_to_user.replies.should == [m]
    end
  end
end
