class Manager::BaseController < ApplicationController

	helper_method :check_access?

	before_action :authenticate_admin!
	before_action :before_filter
	layout 'manager_layout'

	def before_filter
		if admin_signed_in?
			@admin_user = current_admin
		end
	end

	def check_access?(permission)
		unless (!current_admin.permissions.nil?) && (current_admin.permissions.include? permission)
			flash[:warning] = "<strong>Warning!</strong> You are not allowed to access that page."
			redirect_to manager_dashboard_index_path
		end
	end
end