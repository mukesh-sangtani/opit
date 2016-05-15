class RateQuoteOption < ActiveRecord::Base
	belongs_to :rate_quote
	validates :option_type, 
		:presence => {message: "Please select option type."}
	validates :title, 
		:presence => {message: "Please enter title."},
		:uniqueness => {message: "This title already exists.", case_sensitive: false}
	validate :multiple_options

	before_validation :strip_whitespace

	def strip_whitespace
	  	self.title = self.title.strip unless self.title.nil?
	end

	def multiple_options
	end
end