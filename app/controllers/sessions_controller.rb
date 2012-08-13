class SessionsController < ApplicationController
	
	def new
		if signed_in?
      		#redirect_to root_path , notice:"You are signed in."
      		redirect_to current_user , notice:"You are signed in."
      	end
	end
	
	def create
		
		if (params[:session].nil?)
			user_email = params[:email]
			user_password = params[:password]
		else
			user_email = params[:session][:email]
			user_password = params[:session][:password]
		end
		#puts ".............................................................."
		#puts user_email
		#puts user_password
		#puts ".............................................................."

		#user = User.find_by_email(params[:session][:email])
		user = User.find_by_email(user_email)
		#if user && user.authenticate(params[:session][:password])
		if user && user.authenticate(user_password)
			# Sign the user in and redirect to the user's show page.
			sign_in user
			redirect_back_or user 
			#redirect_to user
		else
			# Create an error message and re-render the sign in form
			flash.now[:error] = 'Invalid email/password combination' # Not quite right!
			render 'new'
		end	
	end

	def destroy
		sign_out
		redirect_to root_path
	end
end
