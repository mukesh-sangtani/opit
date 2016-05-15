class Manager::AdminsController < Manager::BaseController
	helper_method :sort_column, :sort_direction

	before_action(only: [:index, :manage_permissions, :edit_password]) { check_access?('users') }
	
	def index
		unless params[:limit]
			params[:limit] = APP_CONFIG['manager_default_limit']
		end
  		@admins = Admin.search(params[:search]).order(sort_column + " " + sort_direction).page(params[:page]).per(params[:limit])

  		if request.xhr?
	      respond_to do |format|
	        format.js {}
	      end
	    else
	      @admin = Admin.new()
	    end
	end

	def change_status
		@admin = Admin.find_by_id(params[:id])
		if @admin.nil?
			@response = {:status => 0, :error_message => "<strong>Error!</strong> Record not found."}
		else
			if @admin.status == APP_CONFIG['status']['Active']
				@admin.status = APP_CONFIG['status']['Inactive']
			else
				@admin.status = APP_CONFIG['status']['Active']
			end
			@admin.save
			@response = {:status => 1, :success_message => "<strong>Success!</strong> User status changed successfully."}
		end
		respond_to do |format|
		    format.json {render json: @response.as_json}
		end
	end

	def destroy
		@rate_master = RateMaster.find(params[:id])
		@response = {:status => 0, :error_messages => {}}
		respond_to do |format|
		    format.json {render json: @response.as_json}
		end
	end

	def edit_password
		@admin = Admin.find(params[:id])
	end

	def update_password
		@admin = Admin.find_by_id(params[:admin][:id])
  		@response = {:status => 0, :error_messages => {}}
		#render plain: @admin.inspect and return
		#@admin.assign_attributes(admin_pass_params)
		#if @admin.save
		if @admin.reset_password(params[:admin][:password],params[:admin][:password_confirmation])
		  # Sign in the admin by passing validation in case their password changed
	  		sign_in @admin, :bypass => true
  			@response[:status] = 1
  			@response[:reload] = "/manager/admins"
  			flash[:success] = "<strong>Success!</strong> Password has been changed successfully."
			#redirect_to manager_path
		else
		  	#render plain: @admin.errors.messages.inspect and return
		  	@admin.errors.messages.each do |key,val|
  				@response[:error_messages]["admin_#{key}"] = val[0]
  			end
		end

		respond_to do |format|
		    format.json {render json: @response.as_json}
		end
	end

	def manage_permissions
		@admin = Admin.find_by_id(params[:id])
		if request.post?
			#new_permission  = params[:permissions].to_yaml
			@admin.permissions = params[:permissions]
			#@admin.assign_attributes(network_params)
			@admin.save
  			flash[:success] = "<strong>Success!</strong> User permissions has been saved successfully."
			redirect_to manager_admins_path
		end
		
	end

	private

	def admin_pass_params
		# NOTE: Using `strong_parameters` gem
		params.require(:admin).permit(:password, :password_confirmation)
	end

	def sort_column
		Admin.column_names.include?(params[:sort]) ? params[:sort] : "name"
	end
	  
	def sort_direction
	    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
	end
end