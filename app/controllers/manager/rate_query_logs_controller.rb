class Manager::RateQueryLogsController < Manager::BaseController
	helper_method :sort_column, :sort_direction

	# def show
	# end

	def index
		check_access?('rate_query_log')
		unless params[:limit]
			params[:limit] = APP_CONFIG['manager_default_limit']
		end

		where_condition = []

		if !params[:destination_id].nil? && !params[:destination_id].blank?
			where_condition << ["destination_id = #{params[:destination_id]}"]
		end

  		@logs = RateQueryLog.joins("LEFT JOIN `destinations` ON (destinations.id = rate_query_logs.destination_id) LEFT JOIN `admins` ON (admins.id = rate_query_logs.user_id AND rate_query_logs.user_type = 'Internal') LEFT JOIN `users` ON (users.id = rate_query_logs.user_id AND rate_query_logs.user_type = 'Client') ").where(where_condition.join(' AND ')).select("rate_query_logs.*, destinations.destination_name, destinations.d_type, admins.email, users.email, count(rate_query_logs.id) as group_count").group("rate_query_logs.group_id").order(sort_column + " " + sort_direction).page(params[:page]).per(params[:limit])

  		#@logs = RateQueryLog.eager_load(:destination, :user, :admin).where(where_condition.join(' AND ')).select("count(rate_query_logs.id) as `group_count`").group("rate_query_logs.group_id").order(sort_column + " " + sort_direction).page(params[:page]).per(params[:limit])

  		#render plain: @logs.methods.sort.inspect and return

  		if request.xhr?
	      respond_to do |format|
	        format.js {}
	      end
	    else
	      @dest_list = Destination.where("status = ? ",APP_CONFIG['status']['Active']).group("d_type").order(d_type: :asc, destination_name: :asc)
	    end
	end

	def session_records
		@grouped_logs = RateQueryLog.joins(:destination).references(:destination).where("rate_query_logs.group_id = ?",params[:id]).select(" rate_query_logs.*, destinations.destination_name, destinations.d_type ").order("rate_query_logs.id asc")
		#render plain: @grouped_logs.methods.sort and return
  		respond_to do |format|
		    format.js {}
		end
	end

private
	def sort_column
		Destination.column_names.include?(params[:sort]) ? params[:sort] : "rate_query_logs.created_at"
	end
	  
	def sort_direction
	    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
	end
end