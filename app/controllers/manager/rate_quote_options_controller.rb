class Manager::RateQuoteOptionsController < Manager::BaseController
	helper_method :sort_column, :sort_direction

	# def show
	# end

	def index 
		unless params[:limit]
			params[:limit] = APP_CONFIG['manager_default_limit']
		end

		where_condition = []

		if !params[:search].nil? && !params[:search].blank?
			where_condition << "(title LIKE '%#{params[:search]}%' OR options LIKE '%#{params[:search]}%')"
		end
		if !params[:option_type].nil? && !params[:option_type].blank?
			where_condition << "option_type = '#{params[:option_type]}'"
		end

  		@rate_quote_options = RateQuoteOption.where(where_condition.join(' AND ')).order(sort_column + " " + sort_direction).page(params[:page]).per(params[:limit])

  		if request.xhr?
	      respond_to do |format|
	        format.js {}
	      end
	    else
	      @rate_quote_option = RateQuoteOption.new()
	    end
	end

	def create
		@rate_quote_option = RateQuoteOption.new(filtered_params)
  		@response = {:status => 0, :error_messages => {}}
  		if @rate_quote_option.save
  			@response[:status] = 1
  			@response[:success_message] = "<strong>Success!</strong> New Option has been saved successfully."
  		else
  			@rate_quote_option.errors.messages.each do |key,val|
  				@response[:error_messages]["rate_quote_option_#{key}"] = val[0]
  			end
  		end

  		respond_to do |format|
		    format.json {render json: @response.as_json}
		end
	end

	def edit
		@rate_quote_option = RateQuoteOption.find(params[:id])
		render :layout => nil
	end

	def update
		@rate_quote_option = RateQuoteOption.find_by_id(params[:id])
  		@response = {:status => 0, :error_messages => {}}
  		@rate_quote_option.assign_attributes(filtered_params)
  		if @rate_quote_option.save
  			@response[:status] = 1
  			@response[:success_message] = "<strong>Success!</strong> Option has been updated successfully."
  		else
  			@rate_quote_option.errors.messages.each do |key,val|
  				@response[:error_messages]["rate_quote_option_#{key}"] = val[0]
  			end
  		end

  		respond_to do |format|
		    format.json {render json: @response.as_json}
		end
	end

	def destroy
		@rate_quote_option = RateQuoteOption.find_by_id(params[:id])
		if @rate_quote_option.nil?
			@response = {:status => 0, :error_message => "<strong>Error!</strong> Record not found."}
		else
			@rate_quote_option.destroy
			@response = {:status => 1, :success_message => "<strong>Success!</strong> Record  deleted successfully."}
		end
		respond_to do |format|
		    format.json {render json: @response.as_json}
		end
	end

private
	def filtered_params
  		params.require(:rate_quote_option).permit(:option_type,:title,:options)
  	end

	def sort_column
		RateQuoteOption.column_names.include?(params[:sort]) ? params[:sort] : "title"
	end
	  
	def sort_direction
	    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
	end
end