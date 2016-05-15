class Document < ActiveRecord::Base
	attr_accessor :attachment_file_size, :attachment_updated_at
	has_attached_file  :attachment,
	 	#:styles => {:thumb => "92x40#"},
	 	:path => ":rails_root/public/documents/:id/:filename",
	 	:url => "documents/:id/:filename"

	validates :title, 
		:presence => {message: "Please enter document title."},
		:uniqueness => {message: "This title already exists.", case_sensitive: false}

	validates :available_to, 
		:presence => {message: "Please select applicability."}

	validates_attachment :attachment, :presence => {message: "Please upload file."}
		#content_type: { content_type: ["image/jpeg", "image/gif", "image/png"], message: "Please upload image only."}
	do_not_validate_attachment_file_type :attachment
	validate :check_sample_comm_text
	before_validation :strip_whitespace

	def strip_whitespace
	  	self.title = self.title.strip unless self.title.nil?
	  	self.sample_text = self.sample_text.strip unless self.sample_text.nil?
	  	self.commercial_text = self.commercial_text.strip unless self.commercial_text.nil?
	end
	
	def self.search(search)
	 	if search
	    	where('title LIKE ? OR attachment_file_name LIKE ?', "%#{search}%", "%#{search}%")
	  	else
	    	where(nil)
	  	end
	end

	def check_sample_comm_text
		if (self.is_sample > 0) &&  (self.sample_text.nil? || self.sample_text.empty?)
			errors.add(:sample_text, "Please enter sample consignment text")
		end

		if (self.is_commercial > 0) &&  (self.commercial_text.nil? || self.commercial_text.empty?)
			errors.add(:commercial_text, "Please enter commercial consignment text")
		end
	end

end