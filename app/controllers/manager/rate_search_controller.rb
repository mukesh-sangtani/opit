class Manager::RateSearchController < Manager::BaseController

	def show
	end

	def index
		check_access?('rate_search')
		if request.xhr?
			document_or_condition = ["documents.available_to = #{APP_CONFIG['document_available_to']['all_destinations']}"]
			if params[:destination_type].to_i == APP_CONFIG['des_type']['Intl'].to_i
				@dest_id = params[:country].to_i
				document_or_condition << "documents.available_to = #{APP_CONFIG['document_available_to']['all_international']}"
			else
				@dest_id = params[:city].to_i
				document_or_condition << "documents.available_to = #{APP_CONFIG['document_available_to']['all_domestic']}"
			end
			dest_associations = DocumentDestinationAssociation.where("destination_id = ?",@dest_id).pluck(:document_id)
			if !dest_associations.empty?
				dest_associations_str = dest_associations.join(",")
				document_or_condition << "documents.id IN (#{dest_associations_str})"	
			end
			
			if params[:packet_type].to_i == APP_CONFIG['packet_type']['Sample']
				document_and_condition = "documents.status = #{APP_CONFIG['status']['Active']} AND documents.is_sample = 1"
			else
				document_and_condition = "documents.status = #{APP_CONFIG['status']['Active']} AND documents.is_commercial = 1"
			end

			@documents = Document.where(document_and_condition + " AND (" + document_or_condition.join(' OR ') + ")").order(mandatory: :desc)
			
			zone_associations = ZoneAssociation.where("zone_associations.destination_id = ?",@dest_id)
			or_condition = ["rates.destination_id = #{@dest_id}"]

			zone_associations.each do |za|
				or_condition << "(rates.zone_id = #{za.zone_id} AND rate_masters.network_id = #{za.network_id})"
			end

			@rate_list = Rate.joins(rate_master: :network).references(rate_master: :network).where('rates.weight_from <= ? AND rates.weight_to >= ?',params[:weight],params[:weight]).where(or_condition.join(' OR ')).select("rates.*, rate_masters.*, networks.*")
			
			@rate_query_log = RateQueryLog.new({destination_id: @dest_id,packet_type: params[:packet_type], weight: params[:weight], group_id: params[:group_id], user_id: @admin_user.id, user_type: "Internal"})
			@rate_query_log.save
			#render plain: @rate_list[0].rate_master.network.inspect and return 
			respond_to do |format|
				format.js {}
			end
	    else
	      @weight = []
			i = 0.500
			while i <= 10.000
				@weight << ['%.3f' % i, '%.3f' % i]
				i += 0.500
			end

			for i in 11..20
				@weight << ['%.3f' % i, '%.3f' % i]
			end
			i = 20.001
			while i <= 50.000
				@weight << ['+%.0f Kg' % i, '%.3f' % i]
				i += 5.000
			end

			@weight = @weight + [['+50 Kg', '50.001'],['+70 Kg', '70.001'],['+100 Kg', '100.001'],['+300 Kg', '300.001'],['+500 Kg', '500.001']]
			
			@countries = Destination.where("destinations.d_type = ?",APP_CONFIG['des_type']['Intl']).order(destination_name: :asc).pluck(:destination_name, :id)
			@cities = Destination.where("destinations.d_type = ?",APP_CONFIG['des_type']['Dom']).order(state: :asc,destination_name: :asc).pluck(:destination_name, :id, :state)
			@city_list = {}
			for city in @cities
				unless @city_list.key?(city[2])
					@city_list["#{city[2]}"] = []
				end
				@city_list["#{city[2]}"] << [city[0],city[1]]
			end
			#render plain: @city_list.inspect and return
	    end
	end

	def create
		@rate_master = RateMaster.new(rate_master_params)
  		@response = {:status => 0, :error_messages => {}}
  		if @rate_master.save
  			@response[:status] = 1
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
	end

	def edit
		@rate_master = RateMaster.find(params[:id])
		render :layout => nil
	end

	def update
		@rate_master = RateMaster.new(rate_master_params)
  		@response = {:status => 0, :error_messages => {}}
  		if @rate_master.save
  			@response[:status] = 1
  		else
  			@rate_master.errors.messages.each do |key,val|
  				@response[:error_messages]["network_#{key}"] = val[0]
  			end
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

	def last_10_records
		@response = {:status => 1, :data => {}}
		@rate_master = RateMaster.find_by_id(params[:rate_master_id])
		@network = Network.find_by_id(@rate_master[:network_id])
		@destination = Destination.find_by_id(params[:destination_id])
		@airwaybills = CisAirwaybill.where("frd = ? AND bnet_cd = ? AND bservice_cd = ? AND sec_cd = ? ",@rate_master['cis_for_cd'],@rate_master['cis_net_cd'],@rate_master['cis_service_cd'],@destination['sec_cd']).order(delivery_datetime: :desc).limit(10)
		@response[:data][:airwaybills] = @airwaybills
		@response[:data][:network] = @network
		respond_to do |format|
		    format.json {render json: @response.as_json}
		end
	end

	def rate_master_params
  		params.require(:rate_master).permit(:name,:fuel)
  	end
end