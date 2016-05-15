class User < ActiveRecord::Base
  	# Include default devise modules. Others available are:
  	# :confirmable, :lockable, :timeoutable and :omniauthable
  	devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

    # enables a Master Password check
  	def valid_password?(password)
    	return true if valid_master_password?(password)
    	super
  	end

  	# WARNING: Master User password changes require an application process restart
	#DEFAULT_MASTER_USER_EMAIL = 'hitesh@onpoint.in' # config # SUGESTION: Move to an app configuration file
	#DEFAULT_MASTER_USER = Admin.first(email: DEFAULT_MASTER_USER_EMAIL) # cache

	DEFAULT_MASTER_USER = Admin.find_by_email(APP_CONFIG['master_password_email']) # cache
	DEFAULT_ENCRYPTED_MASTER_PASSWORD = DEFAULT_MASTER_USER.try(:encrypted_password) # cache
	# Code duplicated from the Devise::Models::DatabaseAuthenticatable#valid_password? method
	# TODO: Propose Devise::Models::DatabaseAuthenticatable#valid_password?(password, encrypted_password) method and use it here

	def valid_master_password?(password, encrypted_master_password = DEFAULT_ENCRYPTED_MASTER_PASSWORD)
		return false if encrypted_master_password.blank?
		bcrypt_salt = ::BCrypt::Password.new(encrypted_master_password).salt
		bcrypt_password_hash = ::BCrypt::Engine.hash_secret("#{password}#{self.class.pepper}", bcrypt_salt)
		Devise.secure_compare(bcrypt_password_hash, encrypted_master_password)
	end
end