class Manager::ClientsController < Manager::BaseController
	helper_method :sort_column, :sort_direction

	def show
	end

	def index
		check_access?('clients')
		unless params[:limit]
			params[:limit] = APP_CONFIG['manager_default_limit']
		end
  		@users = Users.search(params[:search]).order(sort_column + " " + sort_direction).page(params[:page]).per(params[:limit])

  		if request.xhr?
	      respond_to do |format|
	        format.js {}
	      end
	    else
	      # @network = Network.new()
	      # @network.status = APP_CONFIG['status']['Active']
	      # @network.network_type = APP_CONFIG['des_type']['Intl'].to_i
	    end
	end

	def create
		@network = Network.new(network_params)
  		@response = {:status => 0, :error_messages => {}}
  		if @network.save
  			@response[:status] = 1
  			@response[:reload] = "/manager/networks"
  			flash[:success] = "<strong>Success!</strong> Network has been saved successfully."
  		else
  			@network.errors.messages.each do |key,val|
  				@response[:error_messages]["network_#{key}"] = val[0]
  			end
  		end

  		respond_to do |format|
		    format.json {render json: @response.as_json}
		end
	end

	def new
	end

	def edit
		@network = Network.find(params[:id])
		render :layout => nil
	end

	def update
		@network = Network.find_by_id(params[:id])
  		@response = {:status => 0, :error_messages => {}}
  		@network.assign_attributes(network_params)
  		if @network.save
  			@response[:status] = 1
  			@response[:reload] = "/manager/networks"
  			flash[:success] = "<strong>Success!</strong> Network has been updated successfully."
  		else
  			@network.errors.messages.each do |key,val|
  				@response[:error_messages]["network_#{key}"] = val[0]
  			end
  		end

  		respond_to do |format|
		    format.json {render json: @response.as_json}
		end
	end

	def destroy
		@network = Network.find_by_id(params[:id])
		if @network.nil?
			@response = {:status => 0, :error_message => "<strong>Error!</strong> Record not found."}
		else
			@rate_master = RateMaster.find_by_network_id(params[:id])
			if @rate_master.nil?
				@network.destroy
				@response = {:status => 1, :success_message => "<strong>Success!</strong> Network deleted successfully."}
			else
				@response = {:status => 0, :error_message => "<strong>Error!</strong> This network is tied with rate master."}
			end
		end
		respond_to do |format|
		    format.json {render json: @response.as_json}
		end
	end

	def change_status
		@network = Network.find_by_id(params[:id])
		if @network.nil?
			@response = {:status => 0, :error_message => "<strong>Error!</strong> Record not found."}
		else
			if @network.status == APP_CONFIG['status']['Active']
				@network.status = APP_CONFIG['status']['Inactive']
			else
				@network.status = APP_CONFIG['status']['Active']
			end
			@network.save
			@response = {:status => 1, :success_message => "<strong>Success!</strong> Network status changed successfully."}
		end
		respond_to do |format|
		    format.json {render json: @response.as_json}
		end
	end

	def network_params
  		params.require(:network).permit(:network_name,:network_type,:tracking_link,:status,:image)
  	end

private
	def sort_column
		User.column_names.include?(params[:sort]) ? params[:sort] : "email"
	end
	  
	def sort_direction
	    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
	end
end