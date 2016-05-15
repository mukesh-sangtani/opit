class SearchController < ApplicationController

	#layout :resolve_layout

	before_action :authenticate_user!
	def index
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
		#render plain: @weight.inspect and return
  	end

  	def search_rate
  		if params[:destination_type].to_i == APP_CONFIG['des_type']['Intl'].to_i
			@dest_id = params[:country].to_i
		else
			@dest_id = params[:city].to_i
		end
		zone_associations = ZoneAssociation.where("zone_associations.destination_id = ?",@dest_id)
		or_condition = ["rates.destination_id = #{@dest_id}"]

		zone_associations.each do |za|
			or_condition << "(rates.zone_id = #{za.zone_id} AND rate_masters.network_id = #{za.network_id})"
		end

		@destination = Destination.find_by_id(@dest_id)

		@rate_list = Rate.joins(rate_master: :network).references(rate_master: :network).where('rates.weight_from <= ? AND rates.weight_to >= ? AND rate_masters.show_to_client = ? AND rate_masters.status = ?',params[:weight],params[:weight],APP_CONFIG['state']['Enabled'],APP_CONFIG['state']['Enabled']).where(or_condition.join(' OR ')).select("rates.*, rate_masters.*, networks.*")

		@standard_rates = []
		@economic_rates = []
		@express_rates = []

		for rate_record in @rate_list
			if params[:weight].to_f > 20.000
	          if rate_record.rate_type == APP_CONFIG['rate_type']['Basic']
	            cost = (rate_record.rate / rate_record.weight_to).round
	          else
	            cost = rate_record.rate.round
	          end
	        else
	          if rate_record.rate_type == APP_CONFIG['rate_type']['Basic']
	            cost = rate_record.rate
	          else
	            cost = (rate_record.rate * params[:weight].to_f).round
	          end
	        end
	        
	        if rate_record.rate_master.margin_type == APP_CONFIG['margin_type']['Percent']
	          margin = ((cost * rate_record.rate_master.margin)/100).round
	        else
	          margin = rate_record.rate_master.margin.round
	        end
	        rate = cost + margin
	        fuel = ((rate*rate_record.rate_master.fuel)/100).round
	        if rate_record.rate_master.s_tax.to_i > 0
	          s_tax = (((rate + fuel)*APP_CONFIG['service_tax'].to_f)/100).round
	        else
	          s_tax = 0
	        end
	        rate_record.cln_cost 		= cost
	        rate_record.cln_margin 		= margin
	        rate_record.cln_rate 		= rate
	        rate_record.cln_fuel 		= fuel
	        rate_record.cln_stax 		= s_tax
	        rate_record.cln_total 		= rate + fuel + s_tax
	        rate_record.cln_rate_breakup = rate.to_s + " + " + fuel.to_s + "(" +rate_record.rate_master.fuel.to_s+ "%)" + " + " +s_tax.to_s + "(" +APP_CONFIG['service_tax']+ "%)"

			@airwaybills = CisAirwaybill.where("frd = ? AND bnet_cd = ? AND bservice_cd = ? AND sec_cd = ? ",rate_record.rate_master.cis_for_cd,rate_record.rate_master.cis_net_cd,rate_record.rate_master.cis_service_cd,@destination['sec_cd']).order(delivery_datetime: :desc).limit(10)

			rate_record.last_10_records = @airwaybills
			
			#render plain: rate_record.cln_stax.inspect and return
			case rate_record.rate_master.category_id
				when APP_CONFIG['rate_master_category']['Express']
					@express_rates << rate_record
				when APP_CONFIG['rate_master_category']['Standard']
					@standard_rates << rate_record
				else
					@economic_rates << rate_record
			end
		end

		if !@standard_rates.blank? && @standard_rates.count > 1
			@standard_rates = bubble_sort(@standard_rates)
		end

		if !@economic_rates.blank? && @economic_rates.count > 1
			@economic_rates = bubble_sort(@economic_rates)
		end

		if !@express_rates.blank? && @express_rates.count > 1
			@express_rates = bubble_sort(@express_rates)
		end

		@rate_query_log = RateQueryLog.new({destination_id: @dest_id,packet_type: params[:packet_type], weight: params[:weight], group_id: params[:group_id], user_id: @front_user.id, user_type: "Client"})
		@rate_query_log.save
  		render :layout => false
  	end

  	private

  	def bubble_sort(array)
	  	n = array.length
	  	loop do
	    	swapped = false
	    	(n-1).times do |i|
			    if array[i].cln_total.to_i > array[i+1].cln_total.to_i
			        array[i], array[i+1] = array[i+1], array[i]
			        swapped = true
			    end
	    	end
	    	break if not swapped
	  	end
	  	array
	end
end