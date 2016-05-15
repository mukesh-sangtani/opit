class Zone < ActiveRecord::Base
	validates :zone_code, 
		:presence => {message: "Please enter zone code."},
		:uniqueness => {message: "This zone code already exists.", case_sensitive: false}
	validates :zone_name, 
		:presence => {message: "Please enter zone name."},
		:uniqueness => {message: "This zone name already exists.", case_sensitive: false}
	validates :display_order, :on => :update,
		:presence => {message: "Please enter display order."}

	before_validation :strip_whitespace

	def strip_whitespace
	  	self.zone_code = self.zone_code.strip unless self.zone_code.nil?
	  	self.zone_name = self.zone_name.strip unless self.zone_name.nil?
	end

	def self.search(search)
	 	if search
	    	where('zone_name LIKE ? OR zone_code LIKE ?', "%#{search}%", "%#{search}%")
	  	else
	    	where(nil)
	  	end
	end
end