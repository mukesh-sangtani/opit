class Rate < ActiveRecord::Base
	attr_accessor :cln_cost, :cln_margin, :cln_rate, :cln_fuel, :cln_stax, :cln_total, :cln_rate_breakup, :last_10_records
	belongs_to :rate_master
	belongs_to :destination
	belongs_to :zone
end