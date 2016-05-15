class Manager::RateQuotesController < Manager::BaseController

	def step2
	end

	def step1
		#session[:rate_quote_id] = 6
		@rate_quote = RateQuote.find(session[:rate_quote_id].to_i)
		@rate_quote_data = RateQuoteData.joins("LEFT JOIN `destinations` ON (destinations.id = rate_quote_data.destination_id) LEFT JOIN `rate_masters` ON (rate_masters.id = rate_quote_data.rate_master_id) LEFT JOIN `networks` ON (networks.id = rate_quote_data.network_id)").where("rate_quote_data.rate_quote_id = ?",session[:rate_quote_id].to_i)
		@rate_quote_options = RateQuoteOption.all
	end

	# def show
	# end
	
	def index
		unless params[:limit]
			params[:limit] = APP_CONFIG['manager_default_limit']
		end

		where_condition = []

		if !params[:destination_id].nil? && !params[:destination_id].blank?
			where_condition << ["destination_id = #{params[:destination_id]}"]
		end

  		@rate_quotes = RateQuote.joins(:destination).references(:destination).where(where_condition.join(' AND ')).select("rate_query_logs.*, destinations.destination_name, destinations.d_type, count(rate_query_logs.id) as group_count").group("rate_query_logs.group_id").order(sort_column + " " + sort_direction).page(params[:page]).per(params[:limit])

  		if request.xhr?
	      respond_to do |format|
	        format.js {}
	      end
	    else
	      @dest_list = Destination.where("status = ? ",APP_CONFIG['status']['Active']).group("d_type").order(d_type: :asc, destination_name: :asc)
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

	def rate_quote_session
		@response = {:status => 1, :error_messages => {}}
		if session[:rate_quote_id].nil? || session[:rate_quote_id].blank?
			@rate_quote = RateQuote.new(:admin_id => 1, :status => APP_CONFIG['rate_quote_status_id']['5'])
			@rate_quote.save
			session[:rate_quote_id] = @rate_quote.id
		end

		@rate_quote_data = RateQuoteData.new(:rate_quote_id => session[:rate_quote_id],
			:destination_id => params[:destination_id],
			:weight => params[:weight],
			:rate_master_id => params[:rate_master_id],
			:network_id => params[:network_id],
			:rate => params[:rate]
			)
		@rate_quote_data.save

		respond_to do |format|
		    format.json {render json: @response.as_json}
		end
	end

	def rate_master_params
  		params.require(:rate_master).permit(:name,:fuel)
  	end
end