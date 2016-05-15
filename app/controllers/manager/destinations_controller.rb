class Manager::DestinationsController < Manager::BaseController
	helper_method :sort_column, :sort_direction

	# def show
	# end

	def index
		check_access?('destination_country_list')

		unless params[:limit]
			params[:limit] = APP_CONFIG['manager_default_limit']
		end
  		@countries = Destination.country_search(params[:search]).order(sort_column + " " + sort_direction).page(params[:page]).per(params[:limit])

  		if request.xhr?
	      respond_to do |format|
	        format.js {}
	      end
	    else
	      @destination = Destination.new()
	      @destination.status = APP_CONFIG['status']['Active']
	      @destination.d_type = APP_CONFIG['des_type']['Intl']
	    end
	end

	def city_list
		check_access?('destination_city_list')
		unless params[:limit]
			params[:limit] = APP_CONFIG['manager_default_limit']
		end

		where_condition = ["d_type = #{APP_CONFIG['des_type']['Dom']}"]

		if !params[:search].nil? && !params[:search].blank?
			where_condition << "destination_name LIKE '%#{params[:search]}%'"
		end
		
		if !params[:state].nil? && !params[:state].blank?
			where_condition << "state = '#{params[:state]}'"
		end

  		@cities = Destination.where(where_condition.join(' AND ')).order(sort_column + " " + sort_direction).page(params[:page]).per(params[:limit])

  		if request.xhr?
	      respond_to do |format|
	        format.js {}
	      end
	    else
	      @destination = Destination.new()
	      @destination.status = APP_CONFIG['status']['Active']
	      @destination.d_type = APP_CONFIG['des_type']['Dom']
	      @state_list = Destination.where("d_type = ? ",APP_CONFIG['des_type']['Dom']).group("state")
	    end
	end

	def create
		@destination = Destination.new(country_params)
  		@response = {:status => 0, :error_messages => {}}
  		if @destination.save
  			@response[:status] = 1
  			@response[:success_message] = "<strong>Success!</strong> Country has been saved successfully."
  		else
  			@destination.errors.messages.each do |key,val|
  				@response[:error_messages]["destination_#{key}"] = val[0]
  			end
  		end

  		respond_to do |format|
		    format.json {render json: @response.as_json}
		end
	end

	def create_city
		@destination = Destination.new(city_params)
  		@response = {:status => 0, :error_messages => {}}
  		@destination.country = 'IN'
  		if @destination.save
  			@response[:status] = 1
  			@response[:success_message] = "<strong>Success!</strong> City record has been saved successfully."
  		else
  			@destination.errors.messages.each do |key,val|
  				@response[:error_messages]["destination_#{key}"] = val[0]
  			end
  		end

  		respond_to do |format|
		    format.json {render json: @response.as_json}
		end
	end

	def edit
		@destination = Destination.find(params[:id])
		render :layout => nil
	end

	def edit_city
		@destination = Destination.find(params[:id])
	    @state_list = Destination.where("d_type = ? ",APP_CONFIG['des_type']['Dom']).group("state")
		render :layout => nil
	end

	def update
		@destination = Destination.find_by_id(params[:id])
  		@response = {:status => 0, :error_messages => {}}
  		@destination.assign_attributes(country_params)
  		if @destination.save
  			@response[:status] = 1
  			@response[:success_message] = "<strong>Success!</strong> Country record has been updated successfully."
  		else
  			@destination.errors.messages.each do |key,val|
  				@response[:error_messages]["destination_#{key}"] = val[0]
  			end
  		end

  		respond_to do |format|
		    format.json {render json: @response.as_json}
		end
	end

	def update_city
		@destination = Destination.find_by_id(params[:destination][:id])
  		@response = {:status => 0, :error_messages => {}}
  		@destination.assign_attributes(city_params)
  		if @destination.save
  			@response[:status] = 1
  			@response[:success_message] = "<strong>Success!</strong> City record has been updated successfully."
  		else
  			@destination.errors.messages.each do |key,val|
  				@response[:error_messages]["destination_#{key}"] = val[0]
  			end
  		end

  		respond_to do |format|
		    format.json {render json: @response.as_json}
		end
	end

	def destroy
		@destination = Destination.find_by_id(params[:id])
		if @destination.nil?
			@response = {:status => 0, :error_message => "<strong>Error!</strong> Record not found."}
		else
			@destination.destroy
			@response = {:status => 1, :success_message => "<strong>Success!</strong> Record  deleted successfully."}
		end
		respond_to do |format|
		    format.json {render json: @response.as_json}
		end
	end

	def change_status
		@destination = Destination.find_by_id(params[:id])
		if @destination.nil?
			@response = {:status => 0, :error_message => "<strong>Error!</strong> Record not found."}
		else
			if @destination.status == APP_CONFIG['status']['Active']
				@destination.status = APP_CONFIG['status']['Inactive']
			else
				@destination.status = APP_CONFIG['status']['Active']
			end
			@destination.save
			@response = {:status => 1, :success_message => "<strong>Success!</strong> Record  changed successfully."}
		end
		respond_to do |format|
		    format.json {render json: @response.as_json}
		end
	end


private
	def country_params
  		params.require(:destination).permit(:destination_name,:d_type,:status)
  	end

  	def city_params
  		params.require(:destination).permit(:destination_name,:d_type,:state,:status)
  	end

	def sort_column
		Destination.column_names.include?(params[:sort]) ? params[:sort] : "destination_name"
	end
	  
	def sort_direction
	    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
	end
end