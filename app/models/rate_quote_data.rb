class RateQuoteData < ActiveRecord::Base
	belongs_to :rate_quote, :counter_cache => true
	belongs_to :rate_master
	belongs_to :destination
	belongs_to :network
end