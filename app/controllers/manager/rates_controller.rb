class Manager::RatesController < Manager::BaseController

	def manage_rates
		if params[:id].blank?
			flash[:warning] = "<strong>Warning!</strong> Please select a rate master to feed rates."
			redirect_to manager_rate_masters_url #, alert: "Please select rate master first."
			return
		end
		@rate_master = RateMaster.joins(:network).references(:network).find_by_id(params[:id])
		#render plain: @rate_master.network.inspect and return
		if @rate_master.network.network_type == APP_CONFIG['des_type']['Intl']
			@countries = Destination.where("destinations.d_type = ?",APP_CONFIG['des_type']['Intl']).order(destination_name: :asc).pluck(:destination_name, :id)
		else
			@cities = Destination.where("destinations.d_type = ?",APP_CONFIG['des_type']['Dom']).order(state: :asc,destination_name: :asc).pluck(:destination_name, :id, :state)
			@city_list = {}
			for city in @cities
				unless @city_list.key?(city[2])
					@city_list["#{city[2]}"] = []
				end
				@city_list["#{city[2]}"] << [city[0],city[1]]
			end
		end

		@selected_zone_list = ZoneAssociation.joins(:zone).references(:zone).where('zone_associations.network_id = ?',@rate_master.network.id).select("zone_associations.*, zones.*").order("zones.display_order").group('zone_associations.zone_id')

		@feeded_zone_list = Rate.joins(:zone).references(:zone).where('rates.rate_master_id = ? AND rates.zone_id IS NOT NULL',@rate_master.id).select("rates.*, zones.*").order("zones.display_order").group('rates.zone_id')

		@feeded_dest_list = Rate.joins(:destination).references(:destination).where('rates.rate_master_id = ? AND rates.destination_id IS NOT NULL',@rate_master.id).select("rates.*, destinations.*").order("destinations.destination_name").group('rates.destination_id')
		#render plain: @feeded_dest_list.inspect and return

	end

	def save_rates
		@response = {:status => 0, :error_messages => []}
		@flat_list  = !(params[:rate][:flat_weight_start].nil?) ? params[:rate][:flat_weight_start] : []
		@perkg_list  = !(params[:rate][:perkg_weight_start].nil?) ? params[:rate][:perkg_weight_start] : []

		#  1. Arrange rows in ascending order
		#  2. Check if end weight of last row >= start weight of current row
		
		@combo_list = []
		i = 0
		#render plain: @flat_list.methods and return
		@flat_list.each do |flat_rate|
			@combo_list <<  {:row_no =>i, :type => 'flat_rate', :start => flat_rate, :end => params[:rate][:flat_weight_end][i],:rate => params[:rate][:flat_rate][i], :comment => params[:rate][:flat_comment][i]}
			i += 1
		end

		i = 0
		@perkg_list.each do |perkg_rate|
			@combo_list <<  {:row_no =>i, :type => 'perkg_rate', :start => perkg_rate, :end => params[:rate][:perkg_weight_end][i],:rate => params[:rate][:perkg_rate][i], :comment => params[:rate][:perkg_comment][i]}
			i += 1
		end

		@combo_list = selection_sort(@combo_list)

		last_val = 0
		@combo_list.each do |combo_rate|
			if last_val.to_f >= combo_rate[:start].to_f
				@response[:error_messages] << combo_rate
			end
			last_val = combo_rate[:end]
		end

		if @response[:error_messages].blank?
			dely_days = params[:rate][:dely_days].split("-")
			delete_where = ["rate_master_id = #{params[:rate][:rate_master_id]}"]
			if params[:rate][:feed_rate_for].to_i == 1
				zone_id = params[:rate][:zone_id]
				destination_id = nil
				delete_where << ["zone_id = #{params[:rate][:zone_id]}"]
				Rate.where(delete_where.join(' AND ')).delete_all

				@combo_list.each do |combo_rate|
					@save_rate = Rate.new(:rate_master_id => params[:rate][:rate_master_id],:zone_id => zone_id, :destination_id => destination_id, :weight_from => combo_rate[:start], :weight_to => combo_rate[:end], :rate => combo_rate[:rate], :remarks => combo_rate[:comment], :dely_1 => dely_days[0], :dely_2 => dely_days[1])
					if combo_rate[:type] == 'flat_rate'
						@save_rate[:rate_type] = 1
					else
						@save_rate[:rate_type] = 2
					end
					@save_rate.save
				end
			else
				zone_id = nil
				delete_where << ["destination_id IN (#{params[:rate][:country_id].join(",")})"]
				Rate.where(delete_where.join(' AND ')).delete_all
				for destination_id in params[:rate][:country_id]
					@combo_list.each do |combo_rate|
						@save_rate = Rate.new(:rate_master_id => params[:rate][:rate_master_id],:zone_id => zone_id, :destination_id => destination_id, :weight_from => combo_rate[:start], :weight_to => combo_rate[:end], :rate => combo_rate[:rate], :remarks => combo_rate[:comment], :dely_1 => dely_days[0], :dely_2 => dely_days[1])
						if combo_rate[:type] == 'flat_rate'
							@save_rate[:rate_type] = 1
						else
							@save_rate[:rate_type] = 2
						end
						@save_rate.save
					end
				end
			end

			@response[:status] = 1
			@response[:feed_for] = params[:rate][:feed_rate_for]
  			@response[:success_message] = "<strong>Success!</strong> Rates has been saved successfully."
		end

		respond_to do |format|
		    format.json {render json: @response.as_json}
		end
	end

	def load_rates 
		@response = {:status => 1, :flat_list => [], :perkg_list => []}

		if params[:edit_type] == '1'
			where_condition = ["rate_master_id = #{params[:rate_master_id]}","zone_id = #{params[:zone_id]}"]
		else
			where_condition = ["rate_master_id = #{params[:rate_master_id]}","destination_id IN (#{params[:dest_id].join(",")})"]
		end

		@response[:flat_list] = Rate.where(where_condition.join(" AND ")).where("rate_type = #{APP_CONFIG['rate_type']['Basic']}").order("id")

		@response[:perkg_list] = Rate.where(where_condition.join(" AND ")).where("rate_type = #{APP_CONFIG['rate_type']['Perkg']}").order("id")

		respond_to do |format|
		    format.json {render json: @response.as_json}
		end
	end

	def delete_rates
		@response = {:status => 1}

		if params[:edit_type].to_i == 1
			Rate.where("rate_master_id = #{params[:rate_master_id]} AND  zone_id = #{params[:zone_id]}").delete_all
		else
			Rate.where("rate_master_id = #{params[:rate_master_id]} AND destination_id = #{params[:dest_id]}").delete_all
		end

		respond_to do |format|
		    format.json {render json: @response.as_json}
		end
	end

    def load_master_list
    	if params[:feed_for].to_i == 1
    		@feeded_zone_list = Rate.joins(:zone).references(:zone).where('rates.rate_master_id = ? AND rates.zone_id IS NOT NULL',params[:rate_master_id]).select("rates.*, zones.*").order("zones.display_order").group('rates.zone_id')
    		@type = "Zone"
    	else
			@feeded_dest_list = Rate.joins(:destination).references(:destination).where('rates.rate_master_id = ? AND rates.destination_id IS NOT NULL',params[:rate_master_id]).select("rates.*, destinations.*").order("destinations.destination_name").group('rates.destination_id')
			@type = "Country"
    	end

    	respond_to do |format|
		    format.js { render "load_master_list", :locals => {:feed_for => params[:feed_for],:type => @type} }
		end
    end

private

	def bubble_sort(array)
	  	n = array.length
	  	loop do
	    	swapped = false
	    	(n-2).times do |i|
			    if array[i][:end].to_f > array[i+1][:start].to_f
			        array[i], array[i+1] = array[i+1], array[i]
			        swapped = true
			    end
	    	end
	    	break if not swapped
	  	end
	  	array
	end

	def selection_sort(to_sort)
        for index in 0..(to_sort.length - 2)
            # select the first element as the temporary minimum
            index_of_minimum = index
 
            # iterate over all other elements to find the minimum
            for inner_index in index..(to_sort.length - 1)
                if to_sort[inner_index][:start].to_f < to_sort[index_of_minimum][:end].to_f
                    index_of_minimum = inner_index
                end
            end
 
            if index_of_minimum != index
                to_sort[index], to_sort[index_of_minimum] = to_sort[index_of_minimum], to_sort[index]
            end
        end
 
        return to_sort
    end


end