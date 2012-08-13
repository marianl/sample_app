require_relative '../helpers/linktonew.rb'

class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  include LinkToNew

  #puts ancestors.inspect

end
