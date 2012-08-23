require 'spec_helper'

describe "Static Pages" do
  
  #a#let(:base_title) { "Ruby on Rails Tutorial Sample App" }

  subject { page }

  shared_examples_for "all static pages" do
    it { should have_selector('h1', text: heading) }
    it { should have_selector('title', text: full_title(page_title)) }
  end

  describe "Home page" do
    before { visit root_path }


    let(:heading) { 'Sample App' }
    let(:page_title) { '' }

    it_should_behave_like "all static pages"
    #c#it { should have_selector('h1',        text: 'Sample App') }
    #c#it { should have_selector('title',     text: full_title('')) }
    it { should_not have_selector('title', text: '| Home') } 

    describe "for signed-in users" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        FactoryGirl.create(:micropost, user:user, content: "Lorem ipsum")
        FactoryGirl.create(:micropost, user:user, content: "Dolor sit amet")
        sign_in user
        visit root_path
      end

      it "should render the user's feed" do
        user.feed.each do |item|
          page.should have_selector("li##{item.id}", text: item.content)
        end
      end

      describe "follower/following counts" do
        let(:other_user) { FactoryGirl.create(:user) }
        before do
          other_user.follow!(user)
          visit root_path
        end

        it { should have_link("0 following", href: following_user_path(user)) }
        it { should have_link("1 followers", href: followers_user_path(user)) }
      end
    end  

    #b#it { should have_selector('h1', :text => "Sample App") }
    #b#it { should have_selector('title', :text => "#{base_title}") }
    #b#it { should_not have_selector('title', :text => '| Home') }

    #a#it "should have the h1 'Sample App'" do
    #a#  page.should have_selector('h1', :text => "Sample App")
    #a#end

    #a#it "should have the base title" do
    #a#  page.should have_selector('title', :text => "#{base_title}")
    #a#end

    #a#it "should not have a custom page title" do
    #a#  page.should_not have_selector('title', :text => '| Home')
    #a#end

  end

  describe "Help page" do
    before { visit help_path }


    let(:heading) { 'Help' }
    let(:page_title) { 'Help' }

    it_should_behave_like "all static pages"


    #c#it { should have_selector('h1',    text: 'Help') }
    #c#it { should have_selector('title', text: full_title('Help')) }
  	#a#it "should have the h1 'Help'" do
  	#a#	visit help_path
  	#a#	page.should have_selector('h1', :text => 'Help')
  	#a#end

    #a#it "should have the title 'Help'" do
    #a#  visit help_path
    #a#  page.should have_selector('title', :text => "#{base_title} | Help")
    #a#end
  end

  describe "About page" do
    before { visit about_path }


    let(:heading) { 'About Us' }
    let(:page_title) { 'About Us' }

    it_should_behave_like "all static pages"
    #c#it { should have_selector('h1',    text: 'About Us') }
    #c#it { should have_selector('title', text: full_title('About Us')) }
  	#a#it "should have h1 'About Us'" do
  	#a#	visit about_path
  	#a#	page.should have_selector('h1', :text => 'About Us')
  	#a#end

    #a#it "should have the title 'About Us'" do
    #a#  visit about_path
    #a#  page.should have_selector('title', :text => "#{base_title} | About Us")
    #a#end
  end

  describe "Contact page" do
    before { visit contact_path }


    let(:heading) { 'Contact' }
    let(:page_title) { 'Contact' }

    it_should_behave_like "all static pages"

    #c#it { should have_selector('h1',    text: 'Contact') }
    #c#it { should have_selector('title', text: full_title('Contact')) }
    #a#it "should have h1 'Contact'" do
    #a#  visit contact_path
    #a#  page.should have_selector('h1', :text => 'Contact')
    #a#end

    #a#it "should have the title 'Contact'" do
    #a#  visit contact_path
    #a#  page.should have_selector('title', :text => "#{base_title} | Contact")
    #a#end
  end

  it "should have the right links on the layout" do
     visit root_path
     click_link "About"
     page.should have_selector 'title', text: full_title('About Us')
     click_link "Help"
     page.should have_selector 'title', text: full_title('Help')
     click_link "Contact"
     page.should have_selector 'title', text: full_title('Contact')
     click_link "Home"
     click_link "Sign up now!"
     page.should have_selector 'title', text: full_title('Sign up')
     click_link "Sample App"
     page.should have_selector 'title', text: full_title('')
  end
end
