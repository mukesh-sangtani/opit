class Network < ActiveRecord::Base
	attr_accessor :image_content_type, :image_file_size, :image_updated_at
	has_attached_file  :image,
	 	:styles => {:thumb => "92x40#"},
	 	:path => ":rails_root/public/networks/:id/:style/:filename",
	 	:url => "networks/:id/:style/:filename"

	has_many :rate_masters
	has_many :zone_associations
	validates :network_name, 
		:presence => {message: "Please enter network name."},
		:uniqueness => {message: "This network name already exists.", case_sensitive: false}

	validates_attachment :image, :presence => {message: "Please upload image."},
		content_type: { content_type: ["image/jpeg", "image/gif", "image/png"], message: "Please upload image only."}

	validates :image, :unless => "image.queued_for_write[:original].blank?", :dimensions => { :width => 92, :height => 40 }

	before_validation :strip_whitespace

	def strip_whitespace
	  	self.network_name = self.network_name.strip unless self.network_name.nil?
	  	self.tracking_link = self.tracking_link.strip unless self.tracking_link.nil?
	end
	
	def self.search(search)
	 	if search
	    	where('network_name LIKE ?', "%#{search}%")
	  	else
	    	where(nil)
	  	end
	end


	def network_name_unique
		if !self.network_name.empty?
			# @check_network = self.where('network.network_name = ? AND network.id <> ?',network_name,id)
			# #errors.add(:network_name, "Error message222")
			# if @check_network.nil?
			# 	errors.add(:network_name, "Error message1")
			# end
			if self.where('network.network_name = ? AND network.id <> ?',self.network_name,self.id).exists?
				errors.add(:network_name, "Error message11")
			else
				errors.add(:network_name, "Error message22")
			end
		else
			errors.add(:network_name, "Error message2")
		end
	end
end
