FactoryGirl.define do
	factory :user do
		sequence(:name)  { |n| "Person #{n}" }
		sequence(:email) { |n| "person_#{n}@example.com" }
		#name "Michael Harlt"
		#email "michael@example.com"
		password "foobar"
		password_confirmation "foobar"

		factory :admin do
			admin true
		end
	end

	factory :micropost do
		content "Lorem ipsum"
		user
	end


	factory :wrong_user, class: User do
		name "Michael Harlt"
		email "wrong@example.com"
		password "foobar"
		password_confirmation "foobar"
	end

	factory :userToReplyTo, class: User do |user|
		user.name "User To Reply"
		user.email "usertoreplay@example.com"
		user.password "foobar"
		user.password_confirmation "foobar"
	end

	factory :micropost_to_user_to_replay do |micropost|
		micropost.content "@User_To_Reply Private micropost"
		micropost.association :user
	end
end