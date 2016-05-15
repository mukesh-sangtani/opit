class ZoneAssociation < ActiveRecord::Base
	belongs_to :zone
	belongs_to :network
	belongs_to :destination #, :foreign_key => "country_id"
end