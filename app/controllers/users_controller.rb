class UsersController < ApplicationController
	before_action :authenticate_user!

	def index
		@user = User.new
  	end

  	def show
		@user = User.new
		exit(1)
  	end

  	def add
		#@user = User.new
		user = User.find(1)
		Rails.logger.debug("My object: #{user.inspect}")
		user.add_role :admin
		Rails.logger.debug("My object: #{@role_check.inspect}")
		abort("request")
  	end
end