require 'spec_helper'

describe "Micropost pages" do
  
	subject { page }

	let(:user) { FactoryGirl.create(:user) }
	before { sign_in user }

	describe "micropost creation" do
		before { visit root_path }

		describe "with invalid information" do

			it "should not create a micropost" do
				expect { click_button "Post" }.should_not change(Micropost, :count)
			end

			describe "error messages" do 
				before { click_button "Post" }
				it { should have_content('error') }
			end
		end

		describe "with valid information" do
			
			before { visit root_path }
			it { should have_link('view my profile') }
			it { should have_content('0 microposts') }

			before { fill_in 'micropost_content', with: "Lorem ipsum 1" }
			it "should create a micropost" do
				expect { click_button "Post" }.should change(Micropost, :count).by(1)
			end

			describe " side bar content when create the first micropost" do
				before do 
					click_button "Post" 
					visit root_path
				end
				it { should have_link('view my profile') }	
				it { should have_content('1 micropost') }

				describe  "side bar pluralize" do 
					before { fill_in 'micropost_content', with: "Lorem ipsum 2" }
					it "should create the second micropost" do
						expect { click_button "Post" }.should change(Micropost, :count).by(1)
					end				
					describe " side bar content when create the second micropost" do
						before do 
							click_button "Post" 
							visit root_path
						end
						it { should have_link('view my profile') }	
						it { should have_content('2 microposts') }
					end				

				end
			end
		end
	end

	describe "micropost destruction" do
		before { 
			FactoryGirl.create(:micropost, user: user) 
			FactoryGirl.create(:micropost, user: user) 
		}

		describe "as correct user" do
			before { visit root_path }

			it "should delete a micropost" do
				expect { click_link "delete" }.should change(Micropost, :count).by(-1)
			end
		end
	end

	describe "micropost pagination" do
		before {
			35.times{ FactoryGirl.create(:micropost, user: user) }
			visit root_path
		}
		after { Micropost.delete_all }

		it { should have_link('view my profile') }
		it { should have_content('35 microposts') }
		it { should have_selector('div.pagination') }

		it "should list each micropost" do
			user.microposts.paginate(page: 1).each do |micropost|
				page.should have_selector('li', text: micropost.content)
			end
		end
	end

	describe "user can't delete micropost of other users" do
		let (:other_user) { FactoryGirl.create(:user, email: "other@example.com") }
		before { visit user_path(other_user) }
		it { should_not have_link "delete" }
	end

	describe "replies" do
		before { visit root_path }
		describe "with invalid username" do 
			before { fill_in 'micropost_content', with: "@invalid_username to reply" }
			it "should not create a micropost" do
				expect { click_button "Post" }.should_not change(Micropost, :count)
			end
			describe "error messages" do 
				before { click_button "Post" }
				it { should have_content("Recipient doesn't exist") }
			end
		end
		describe "with valid username" do
			before do
				@reply_to_user = FactoryGirl.create(:userToReplyTo)
				fill_in 'micropost_content', with: "@User_To_Reply look a reply to User To Reply"
			end
			it "should create a micropost" do
				expect { click_button "Post" }.should change(Micropost, :count).by(1)
			end
		end
		describe "with blank reply" do
			before do 
				@reply_to_user = FactoryGirl.create(:userToReplyTo)
				fill_in 'micropost_content', with: "@User_To_Reply"
			end
			it "should not create a micropost" do
					expect { click_button "Post"}.should_not change(Micropost, :count)
				end
			describe "should raise error" do
				before { click_button "Post" }
				it { should have_content("Reply content can't be blank") }
			end
		end
		describe "with same receiver and sender" do
			before do
				@reply_to_user = FactoryGirl.create(:userToReplyTo)
				click_link 'Sign out'
				sign_in(@reply_to_user)
				visit root_path
				fill_in 'micropost_content', with: "@User_To_Reply"
			end
			it "should not create a reply" do
				expect { click_button "Post"}.should_not change(Micropost, :count)
			end
			describe "should railse error" do
				before { click_button "Post" }
				it { should have_content('error') }
				it { should have_content("You can't reply to yourself") } 
				it { should have_content("Reply content can't be blank") }
			end
		end
	end
end
