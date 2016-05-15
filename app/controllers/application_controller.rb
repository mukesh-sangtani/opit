class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  layout :configure_layout
  
  before_action :before_filter

  def configure_layout
  	if devise_controller? && (resource_name == :user || resource_name == :admin) && action_name == 'new'
      # if params[:controller] == "manager/admin_registrations"
      #   "manager_layout"
      # else
  		  "blank"
      # end
  	else
  		"application"
  	end
  end
  def after_sign_in_path_for(resource)
    #render plain: resource.inspect and return
    if resource.is_a?(User)
      root_url
    else
      manager_url
    end
  end

  def after_sign_up_path_for(resource)
  	#render plain: resource.inspect and return
  	if resource.is_a?(User)
  		root_url
  	else
  		manager_admins_url
  	end
  end

  def after_sign_out_path_for(resource)
    #render plain: resource.inspect and return
    if resource == :user
      root_url
    else
      manager_url
    end
  end
  
  def before_filter
    if user_signed_in?
      @front_user = current_user
    end
  end
end
