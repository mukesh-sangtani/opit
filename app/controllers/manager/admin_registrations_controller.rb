class Manager::AdminRegistrationsController < Devise::RegistrationsController
	before_action :authenticate_admin!
	before_action :before_filter
	#prepend_before_filter :authenticate_scope!, only: [:new, :create, :cancel]
	layout 'manager_layout'

	def before_filter
		if admin_signed_in?
			@admin_user = current_admin
		end
	end

	def new
		build_resource({})
	    set_minimum_password_length
	    resource.status = "1"
	    resource.admin_type = "1"
	    yield resource if block_given?
	    respond_with self.resource
	end

	# POST /resource
	def create
		build_resource(sign_up_params)

		resource.save
		yield resource if block_given?
		if resource.persisted?
		  if resource.active_for_authentication?
		    #set_flash_message :notice, :signed_up if is_flashing_format?
		    #sign_up(resource_name, resource)
		    #respond_with resource, location: after_sign_up_path_for(resource)
		    flash[:success] = "<strong>Success!</strong> New user created successfully."
			redirect_to url_for(controller: "manager/admins", action: "manage_permissions", id: resource.id)
		  else
		    set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
		    expire_data_after_sign_in!
		    respond_with resource, location: after_inactive_sign_up_path_for(resource)
		  end
		else
		  clean_up_passwords resource
		  set_minimum_password_length
		  respond_with resource
		end
	end

  	def edit
		#render plain: params.inspect and return
		self.resource = Admin.find(params[:format])
	end

	def update
	    #self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
	    self.resource = resource_class.to_adapter.get!(params[:"#{resource_name}"][:id])
	    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

	    resource_updated = update_resource(resource, account_update_params)
	    yield resource if block_given?
	    if resource_updated
			# if is_flashing_format?
			# 	flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ?
			# 	  :update_needs_confirmation : :updated
			# 	set_flash_message :notice, flash_key
			# end
			#sign_in resource_name, resource, bypass: true
			#respond_with resource, location: after_update_path_for(resource)
			flash[:success] = "<strong>Success!</strong> User updated successfully."
			redirect_to url_for(controller: "manager/admins", action: "index")
	    else
			clean_up_passwords resource
			respond_with resource
	    end
  	end

	def after_sign_up_path_for(resource)
  		manager_admins_url
  	end

  	def after_update_path_for(resource)
	    manager_admins_url
	end

	def update_resource(resource, params)
	    resource.update_without_password(params)
	end

	private
	
	def sign_up_params
		params.require(:admin).permit(:name, :email, :mobile, :password, :password_confirmation, :admin_type, :status)
	end

	def account_update_params
		params.require(:admin).permit(:name, :email, :mobile, :admin_type, :status)
	end
end