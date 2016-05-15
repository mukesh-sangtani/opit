class Manager::RateMastersController < Manager::BaseController
	helper_method :sort_column, :sort_direction

	def show
	end

	def index
		unless params[:limit]
			params[:limit] = APP_CONFIG['manager_default_limit']
		end
		#RateMaster.clear_cache!
		
		where_condition = []
		if !params[:search].nil? && !params[:search].blank?
			where_condition << "(name LIKE '%#{params[:search]}%' OR fuel LIKE '%#{params[:search]}%' OR margin LIKE '%#{params[:search]}%' OR margin_two LIKE '%#{params[:search]}%' OR packaging_details LIKE '%#{params[:search]}%')"
		end

		if !params[:network_id].nil? && !params[:network_id].blank?
			where_condition << "network_id = '#{params[:network_id]}'"
		end

		if !params[:category_id].nil? && !params[:category_id].blank?
			where_condition << "category_id = '#{params[:category_id]}'"
		end

  		@rate_masters = RateMaster.where(where_condition.join(' AND ')).includes(:network).references(:network).order(sort_column + " " + sort_direction).page(params[:page]).per(params[:limit])

  		if request.xhr?
	      respond_to do |format|
	        format.js {}
	      end
	    end
	end

	def create
		@rate_master = RateMaster.new(rate_master_params)
  		@response = {:status => 0, :error_messages => {}}
  		@rate_master.margin_type = APP_CONFIG['margin_type']['Percent']
  		@rate_master.margin = APP_CONFIG['default_margin_1']
  		@rate_master.margin_two = APP_CONFIG['default_margin_2']
  		if @rate_master.save
  			@response[:status] = 1
  			@response[:reload] = "/manager/rate_masters"
  			flash[:success] = "<strong>Success!</strong> Rate master record has been saved successfully."
  		else
  			@rate_master.errors.messages.each do |key,val|
  				@response[:error_messages]["rate_master_#{key}"] = val[0]
  			end
  		end

  		respond_to do |format|
		    format.json {render json: @response.as_json}
		end
	end

	def new
		@rate_master = RateMaster.new()
	    @rate_master.status = APP_CONFIG['status']['Active']
	    @rate_master.s_tax = APP_CONFIG['state']['Enabled']
	    @rate_master.show_to_client = APP_CONFIG['state']['Enabled']
	end

	def edit
		@rate_master = RateMaster.find(params[:id])
	end

	def edit_margins
		@rate_master = RateMaster.find(params[:id])
	end

	def update
		@rate_master = RateMaster.find_by_id(params[:id])
  		@response = {:status => 0, :error_messages => {}}
  		@rate_master.assign_attributes(rate_master_params)
  		if @rate_master.save
  			@response[:status] = 1
  			@response[:success_message] = "<strong>Success!</strong> Rate master has been updated successfully."
  		else
  			@rate_master.errors.messages.each do |key,val|
  				@response[:error_messages]["rate_master_#{key}"] = val[0]
  			end
  		end

  		respond_to do |format|
		    format.json {render json: @response.as_json}
		end
	end

	def update_margins
		@rate_master = RateMaster.find_by_id(params[:rate_master][:id])
  		@response = {:status => 0, :error_messages => {}}
  		@rate_master.assign_attributes(rate_master_params)
  		if @rate_master.save
  			@response[:status] = 1
  			@response[:success_message] = "<strong>Success!</strong> Margins has been updated successfully."
  		else
  			@rate_master.errors.messages.each do |key,val|
  				@response[:error_messages]["rate_master_#{key}"] = val[0]
  			end
  		end

  		respond_to do |format|
		    format.json {render json: @response.as_json}
		end
	end

	def destroy
		@rate_master = RateMaster.find_by_id(params[:id])
		if @rate_master.nil?
			@response = {:status => 0, :error_message => "<strong>Error!</strong> Record not found."}
		else
			@rate_master.destroy
			@response = {:status => 1, :success_message => "<strong>Success!</strong> Rate Master  deleted successfully."}
		end
		respond_to do |format|
		    format.json {render json: @response.as_json}
		end
	end

	def change_status
		@rate_master = RateMaster.find_by_id(params[:id])
		if @rate_master.nil?
			@response = {:status => 0, :error_message => "<strong>Error!</strong> Record not found."}
		else
			if @rate_master.status == APP_CONFIG['status']['Active']
				@rate_master.status = APP_CONFIG['status']['Inactive']
			else
				@rate_master.status = APP_CONFIG['status']['Active']
			end
			@rate_master.save
			@response = {:status => 1, :success_message => "<strong>Success!</strong> Record  status changed successfully."}
		end
		respond_to do |format|
		    format.json {render json: @response.as_json}
		end
	end

	def update_show_to_client
		@rate_master = RateMaster.find_by_id(params[:id])
		if @rate_master.nil?
			@response = {:status => 0, :error_message => "<strong>Error!</strong> Record not found."}
		else
			if @rate_master.show_to_client == APP_CONFIG['state']['Enabled']
				@rate_master.show_to_client = APP_CONFIG['state']['Disabled']
			else
				@rate_master.show_to_client = APP_CONFIG['state']['Enabled']
			end
			@rate_master.save
			@response = {:status => 1, :success_message => "<strong>Success!</strong> Record  updated successfully."}
		end
		respond_to do |format|
		    format.json {render json: @response.as_json}
		end
	end

	def rate_master_params
  		params.require(:rate_master).permit(:name,:network_id,:category_id,:margin_type,:fixed_cost,:fuel,:s_tax,:margin,:margin_two,:packaging_details,:cis_for_cd,:cis_net_cd,:cis_service_cd,:cis_fetch_data,:cis_fetch_interval,:show_to_client,:status)
  	end

private
	def sort_column
		(!params[:sort].nil? && !params[:sort].blank?) ? params[:sort] : "rate_masters.name"
	end
	  
	def sort_direction
	    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
	end
end