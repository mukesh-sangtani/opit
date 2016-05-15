class RateMaster < ActiveRecord::Base
	has_many :rates
	belongs_to :network

	validates :name, 
		:presence => {message: "Please enter title."},
		:uniqueness => {message: "This title already exists.", case_sensitive: false}
	validates :category_id,
		:presence => {message: "Please select category."}
	validates :network_id,
		:presence => {message: "Please select network."}
	validates :fuel,
		:presence => {message: "Please enter fuel surcharge."}
	
	#with_options :if => :checking do
		validates :margin,
			:presence => {message: "Please enter credit margin."}
		validates :margin_two,
			:presence => {message: "Please enter cash margin."}
	#end

	before_validation :strip_whitespace

	def strip_whitespace
	  	self.name = self.name.strip unless self.name.nil?
	  	self.packaging_details = self.packaging_details.strip unless self.packaging_details.nil?
	end

	def self.search(search)
	 	if search
	    	where('name LIKE ?', "%#{search}%")
	  	else
	    	where(nil)
	  	end
	end

	# def checking
	# 	if self.margin.nil?
	# 		return false
	# 	else
	# 		return true
	# 	end
	# end
end

# class User < ActiveRecord::Base

#   with_options if: :with_password do |record|
#     # some validation and before_filter stuff
#   end

#   with_options if: :resetting_password do |record|
#     # some other validation and before_filter stuff
#   end

#   with_options if: ->{ with_password || resetting_password } do |record|
#     # some common stuff
#   end

# end