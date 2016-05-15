class Destination < ActiveRecord::Base

	validates :destination_name, 
		:presence => {message: "Please enter name."},
		:uniqueness => {message: "This name already exists."}

	def self.city_search(search)
	 	if search
	    	where('d_type = ? AND destination_name LIKE ?', APP_CONFIG['des_type']['Dom'], "%#{search}%")
	  	else
	    	where('d_type = ?', APP_CONFIG['des_type']['Dom'])
	  	end
	end

	def self.country_search(search)
	 	if search
	    	where('d_type = ? AND destination_name LIKE ?', APP_CONFIG['des_type']['Intl'], "%#{search}%")
	  	else
	    	where('d_type = ?', APP_CONFIG['des_type']['Intl'])
	  	end
	end
end