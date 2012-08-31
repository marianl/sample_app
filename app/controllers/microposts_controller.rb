class MicropostsController < ApplicationController
	before_filter :signed_in_user, only: [:create, :destroy]
	before_filter :correct_user,   only: :destroy
#	before_filter :correct_reply_to, only: :create

	@@reply_to_regexp = /\A@([^\s]*)/

	def create
		@micropost = current_user.microposts.build(params[:micropost])
		#- if match = @@reply_to_regexp.match(@micropost.content)
		#-	user = User.find_by_shorthand(match[1])
		#-	if user
		#-		@micropost.in_reply_to = user
		#-		if @micropost.save
		#-			flash[:success] = 'Micropost created!'
		#-			redirect_to root_url
		#-		else
		#-			@feed_items = []
		#-			render 'static_pages/home'
		#-		end
		#-	else
		#-		#- errormessage = "The form contains 1 error:  ;        *  Username '#{match[1]}' doesn't exist"
		#-		#- errormessage = errormessage.gsub(/;/,"\n")
		#-		#- flash[:error] = errormessage + errormessage + errormessage + errormessage + errormessage + errormessage + errormessage #{}"Username doesn't exist"
		#-		@feed_items = []
		#-		redirect_to controller: 'static_pages', action: 'home', defaultcontent: @micropost.content
		#-		#redirect_to root_url
		#-	end
		#-else
			if @micropost.save
				flash[:success] = 'Micropost created!'
				redirect_to root_url
			else
				@feed_items = []
				render 'static_pages/home'
			end
		#-end
	end
	

	def destroy
		@micropost.destroy
		redirect_to root_url
	end

	private
		def correct_user
			@micropost = current_user.microposts.find_by_id(params[:id])
			redirect_to root_url if @micropost.nil?
		end

		#def correct_reply_to
			#@micropost = params[:micropost]
			#if match = @@reply_to_regexp.match(@micropost.content)
			#	puts "match #{@micropost.content}"	
  		#end
		#end
		def extract_in_reply_to
  		if match = @@reply_to_regexp.match(content)
    		user = User.find_by_shorthand(match[1])
    		self.in_reply_to = user if user
  		end
		end
end