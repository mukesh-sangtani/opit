class RateQueryLog < ActiveRecord::Base
	belongs_to :destination
	belongs_to :admin, :foreign_key => "user_id"
	belongs_to :user #, -> {self.select_values = ["users.email"],order("users.email")}
end