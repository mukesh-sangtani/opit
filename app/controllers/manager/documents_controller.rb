class Manager::DocumentsController < Manager::BaseController
	helper_method :sort_column, :sort_direction

	before_action(only: [:index, :new, :edit]) { check_access?('networks') }

	def show
	end

	def index
		check_access?('documents')
		unless params[:limit]
			params[:limit] = APP_CONFIG['manager_default_limit']
		end
  		@documents = Document.search(params[:search]).order(sort_column + " " + sort_direction).page(params[:page]).per(params[:limit])

  		if request.xhr?
	      respond_to do |format|
	        format.js {}
	      end
	    end
	end

	def create
		@document = Document.new(document_params)
  		@response = {:status => 0, :error_messages => {}}
  		if @document.save
  			if @document.available_to == APP_CONFIG['document_available_to']['let_me_choose'].to_i
  				for destination_id in params[:association][:destination_id]
					@save_assoc = DocumentDestinationAssociation.new(:destination_id => destination_id, :document_id => @document.id)
					@save_assoc.save
				end
			end
  			@response[:status] = 1
  			@response[:reload] = "/manager/documents"
  			flash[:success] = "<strong>Success!</strong> New document has been saved successfully."
  		else
  			@document.errors.messages.each do |key,val|
  				@response[:error_messages]["document_#{key}"] = val[0]
  			end
  		end

  		respond_to do |format|
		    format.json {render json: @response.as_json}
		end
	end

	def new
		@document = Document.new()
	    @document.status = APP_CONFIG['status']['Active']
	    @document.is_sample = 0
	    @document.is_commercial = 0
	    @destination_list = {}
		@countries = Destination.where("destinations.d_type = ?",APP_CONFIG['des_type']['Intl']).order(destination_name: :asc).pluck(:destination_name, :id)
		@destination_list["International"] = []
		for country in @countries
			@destination_list["International"] << [country[0],country[1]]
		end

		@cities = Destination.where("destinations.d_type = ?",APP_CONFIG['des_type']['Dom']).order(state: :asc,destination_name: :asc).pluck(:destination_name, :id, :state)
		for city in @cities
			unless @destination_list.key?(city[2])
				@destination_list["#{city[2]}"] = []
			end
			@destination_list["#{city[2]}"] << [city[0],city[1]]
		end
	end

	def edit	
		@document = Document.find(params[:id])
		@dest_associations = ""
		if @document.available_to == APP_CONFIG['document_available_to']['let_me_choose'].to_i
			@dest_associations = DocumentDestinationAssociation.where("document_id = ?",@document.id).pluck(:destination_id)
		end
	    @destination_list = {}
		@countries = Destination.where("destinations.d_type = ?",APP_CONFIG['des_type']['Intl']).order(destination_name: :asc).pluck(:destination_name, :id)
		@destination_list["International"] = []
		for country in @countries
			@destination_list["International"] << [country[0],country[1]]
		end

		@cities = Destination.where("destinations.d_type = ?",APP_CONFIG['des_type']['Dom']).order(state: :asc,destination_name: :asc).pluck(:destination_name, :id, :state)
		for city in @cities
			unless @destination_list.key?(city[2])
				@destination_list["#{city[2]}"] = []
			end
			@destination_list["#{city[2]}"] << [city[0],city[1]]
		end
	end

	def update
		@document = Document.find_by_id(params[:id])
  		@response = {:status => 0, :error_messages => {}}
  		@document.assign_attributes(document_params)
  		if @document.save
			DocumentDestinationAssociation.where("document_id = ?",@document.id).delete_all
			if @document.available_to == APP_CONFIG['document_available_to']['let_me_choose'].to_i
  				for destination_id in params[:association][:destination_id]
					@save_assoc = DocumentDestinationAssociation.new(:destination_id => destination_id, :document_id => @document.id)
					@save_assoc.save
				end
			end

  			@response[:status] = 1
  			@response[:reload] = "/manager/documents"
  			flash[:success] = "<strong>Success!</strong> Document has been updated successfully."
  		else
  			@document.errors.messages.each do |key,val|
  				@response[:error_messages]["document_#{key}"] = val[0]
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
		@document = Document.find_by_id(params[:id])
		if @document.nil?
			@response = {:status => 0, :error_message => "<strong>Error!</strong> Record not found."}
		else
			if @document.status == APP_CONFIG['status']['Active']
				@document.status = APP_CONFIG['status']['Inactive']
			else
				@document.status = APP_CONFIG['status']['Active']
			end
			@document.save
			@response = {:status => 1, :success_message => "<strong>Success!</strong> Document status changed successfully."}
		end
		respond_to do |format|
		    format.json {render json: @response.as_json}
		end
	end

	def document_params
  		params.require(:document).permit(:title,:status,:attachment,:available_to,:mandatory,:is_sample,:sample_text,:is_commercial,:commercial_text)
  	end

private
	def sort_column
		Document.column_names.include?(params[:sort]) ? params[:sort] : "title"
	end
	  
	def sort_direction
	    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
	end
end