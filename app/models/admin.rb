class Admin < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  	devise 	:database_authenticatable, :registerable,
        	:recoverable, :rememberable, :trackable, :validatable
	serialize :permissions
	def self.search(search)
	 	if search
	    	where('name LIKE ?', "%#{search}%")
	  	else
	    	where(nil)
	  	end
	end

	def active_for_authentication?
	  super && self.status == 1 # i.e. super && self.is_active
	end

	def inactive_message
	  "Sorry, this account has been deactivated."
	end

	def find_by_email(email)
		return self.first(email)
	end
end
