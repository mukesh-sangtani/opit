class Manager::NetworksController < Manager::BaseController
	helper_method :sort_column, :sort_direction

	before_action(only: [:index, :manage_zones]) { check_access?('networks') }
	#before_action -> { check_access? 'networks' }, only: %i|index|
	# both above methods are correct

	def show
	end

	def index
		unless params[:limit]
			params[:limit] = APP_CONFIG['manager_default_limit']
		end
  		@networks = Network.search(params[:search]).order(sort_column + " " + sort_direction).page(params[:page]).per(params[:limit])

  		if request.xhr?
	      respond_to do |format|
	        format.js {}
	      end
	    else
	      @network = Network.new()
	      @network.status = APP_CONFIG['status']['Active']
	      @network.network_type = APP_CONFIG['des_type']['Intl'].to_i
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

	def manage_zones
  		@network = Network.find(params[:id])
  		@selected_zone_list = ZoneAssociation.where("zone_associations.network_id = ?",params[:id]).pluck(:zone_id)
  		@zone_association = ZoneAssociation.new
  		@zone_list = Zone.all.order("display_order")
  	end

	def get_zone_assoiation
		@response = {status: 1, country_list: ""}
		
		@network = Network.find_by_id(params[:network_id])

		@networkwide_countries = ZoneAssociation.where("zone_associations.network_id = ? ",params[:network_id])

		zonewide_countries =  []
		otherzone_countries = []

		if @networkwide_countries.blank?
			@country_list = Destination.select("id, destination_name, state").where('d_type = ?',@network.network_type).order(state: :asc, destination_name: :asc)
		else
			for network_loop in @networkwide_countries
				if network_loop.zone_id.to_i  == params[:zone_id].to_i
					zonewide_countries << network_loop.destination_id
				else
					otherzone_countries << network_loop.destination_id
				end
			end
			if otherzone_countries.blank?
				@country_list = Destination.select("id, destination_name, state").where('d_type = ?',@network.network_type).order(state: :asc, destination_name: :asc)
			else
				@country_list = Destination.select("id, destination_name, state").where('d_type = ? AND id NOT IN (?)',@network.network_type, otherzone_countries).order(state: :asc, destination_name: :asc)
			end
		end

		dropdown_data = ""
		if @network.network_type == APP_CONFIG['des_type']['Intl']
			for country_loop in @country_list			
				selected = ""
				if zonewide_countries.include?(country_loop.id)
					selected = 'selected="selected"';
				end
				dropdown_data += "<option #{selected} value='#{country_loop.id}'>#{country_loop.destination_name}</option>"
			end
		else
			state_name = ""
			for country_loop in @country_list			
				selected = ""
				if state_name != country_loop.state
					state_name = country_loop.state
					if state_name.blank?
						dropdown_data += "<optgroup label='#{state_name}'>"
					else
						dropdown_data += "</optgroup><optgroup label='#{state_name}'>"
					end
				end
				if zonewide_countries.include?(country_loop.id)
					selected = 'selected="selected"';
				end
				dropdown_data += "<option #{selected} value='#{country_loop.id}'>#{country_loop.destination_name}</option>"
			end
			dropdown_data += "</optgroup>"
		end

		@response[:country_list] = dropdown_data
  		respond_to do |format|
		    format.json {render json: @response.as_json}
		end
  		
  	end

	def remove_network_zone_association
		@response = {status: 1,success_message: "<strong>Success!</strong> Network-zone association deleted for selected zone."}
  		ZoneAssociation.where("zone_associations.network_id = ? AND zone_associations.zone_id = ? ", params[:network_id], params[:zone_id]).delete_all
  		respond_to do |format|
		    format.json {render json: @response.as_json}
		end
  	end

	def save_zone_association
		@response = {status: 1,success_message: "<strong>Success!</strong> Network-zone association created successfully."}
		#render plain: params.inspect and return
		ZoneAssociation.where("zone_associations.network_id = ? AND zone_associations.zone_id = ? ", params[:network_id], params[:selected_zone]).delete_all

  		params[:country_seletion].each do |destination|
  			@zone_association = ZoneAssociation.new({zone_id: params[:selected_zone],network_id: params[:network_id],destination_id: destination})
  			@zone_association.save
  		end
  		respond_to do |format|
		    format.json {render json: @response.as_json}
		end
  	end

private
	def sort_column
		Network.column_names.include?(params[:sort]) ? params[:sort] : "network_name"
	end
	  
	def sort_direction
	    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
	end
end