require 'spec_helper'

describe "Static Pages" do
  
  #a#let(:base_title) { "Ruby on Rails Tutorial Sample App" }

  subject { page }

  describe "Home page" do
    before { visit root_path }

    it { should have_selector('h1',        text: 'Sample App') }
    it { should have_selector('title',     text: full_title('')) }
    it { should_not have_selector('title', text: '| Home') }   

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

    it { should have_selector('h1',    text: 'Help') }
    it { should have_selector('title', text: full_title('Help')) }
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

    it { should have_selector('h1',    text: 'About Us') }
    it { should have_selector('title', text: full_title('About Us')) }
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

    it { should have_selector('h1',    text: 'Contact') }
    it { should have_selector('title', text: full_title('Contact')) }
    #a#it "should have h1 'Contact'" do
    #a#  visit contact_path
    #a#  page.should have_selector('h1', :text => 'Contact')
    #a#end

    #a#it "should have the title 'Contact'" do
    #a#  visit contact_path
    #a#  page.should have_selector('title', :text => "#{base_title} | Contact")
    #a#end
  end
end
