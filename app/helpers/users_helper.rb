module UsersHelper

	#Returns the Gravatar (http://gravatar.com) for the given user.
	def gravatar_for(user, options = { size: 50})
		gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
		size = options[:size]
		gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
		image_tag(gravatar_url, alt: user.name, class: "gravatar")
	end

	def link_to_destroy(name, url, fallback_url)
		link_to_function name, "confirm_destroy(this, '#{url}'", :href => fallback_url
	end

	 def link_to_function(name, *args, &block)
	 	html_options = args.extract_options!.symbolize_keys
	 	function = block_given? ? update_page(&block) : args[0] || ''
	 	onclick = "#{"#{html_options[:onclick]}; " if html_options[:onclick]}#{function}; return false;"
	 	href = html_options[:href] || '#'
	 	content_tag(:a, name, html_options.merge(:href => href, :onclick => onclick))
	 end
end
