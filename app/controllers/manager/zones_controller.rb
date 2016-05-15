class Manager::ZonesController < Manager::BaseController
	helper_method :sort_column, :sort_direction

	def show
	end

	def index
		check_access?('zones')
		unless params[:limit]
			params[:limit] = APP_CONFIG['manager_default_limit']
		end
  		@zones = Zone.search(params[:search]).order(sort_column + " " + sort_direction).page(params[:page]).per(params[:limit])

  		if request.xhr?
	      respond_to do |format|
	        format.js {}
	      end
	    else
	      @zone = Zone.new()
	    end
	end

	def create
		@zone = Zone.new(zone_params)
  		@response = {:status => 0, :error_messages => {}}
  		#render plain: Zone.maximum("display_order").to_i + 1 and return
  		if @zone.valid?
  			max_display_order = Zone.maximum("display_order").to_i + 1
  			@zone.display_order = max_display_order
  			@zone.save	
  			@response[:status] = 1
  			@response[:success_message] = "<strong>Success!</strong> Zone has been saved successfully."
  		else
  			@zone.errors.messages.each do |key,val|
  				@response[:error_messages]["zone_#{key}"] = val[0]
  			end
  		end

  		respond_to do |format|
		    format.json {render json: @response.as_json}
		end
	end

	def new
	end

	def edit
		@zone = Zone.find(params[:id])
		render :layout => nil
	end

	def update
		@zone = Zone.find_by_id(params[:id])
  		@response = {:status => 0, :error_messages => {}}
  		@zone.assign_attributes(zone_params)
  		if @zone.save
  			@response[:status] = 1
  			@response[:success_message] = "<strong>Success!</strong> Zone has been updated successfully."
  		else
  			@zone.errors.messages.each do |key,val|
  				@response[:error_messages]["zone_#{key}"] = val[0]
  			end
  		end

  		respond_to do |format|
		    format.json {render json: @response.as_json}
		end
	end

	def destroy
		@zone = Zone.find_by_id(params[:id])
		if @zone.nil?
			@response = {:status => 0, :error_message => "<strong>Error!</strong> Record not found."}
		else
			@zone_assoc = ZoneAssociation.find_by_zone_id(params[:id])
			if @zone_assoc.nil?
				@rate_assoc = Rate.find_by_zone_id(params[:id])
				if @rate_assoc.nil?
					@zone.destroy
					@response = {:status => 1, :success_message => "<strong>Success!</strong> Zone deleted successfully."}
				else
					@response = {:status => 0, :error_message => "<strong>Error!</strong> This zone is linked with Rate."}
				end
			else
				@response = {:status => 0, :error_message => "<strong>Error!</strong> This zone is linked in Zone Association."}
			end
		end
		respond_to do |format|
		    format.json {render json: @response.as_json}
		end
	end

	def zone_params
  		params.require(:zone).permit(:zone_name,:zone_code,:display_order)
  	end

private
	def sort_column
		Zone.column_names.include?(params[:sort]) ? params[:sort] : "display_order"
	end
	  
	def sort_direction
	    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
	end
end