class CronController < ApplicationController

	#layout :resolve_layout

	#before_action :authenticate_user!
	def fetch_cis_awb_data
		#c = Curl::Easy.new("http://122.160.165.182:1079/onpoint.in/reply.php?awb=700149698&callback=jsonCallback&_=1461498872359")
		#c.perform
		#render plain: c.body_str and return

		# http = Curl.post(APP_CONFIG['cis_fetch_data'], {:for_cd => "deep",:net_cd => "fed",:service_cd => "exp",:date1 => "2016-03-28",:date2 => "2016-03-31"})
		# render plain: http.body_str and return
		
		dt1 = Time.now.months_ago(1)
		dt2 = dt1 + 5.days
		#render plain: dt1.to_date.to_formatted_s(:db).inspect and return
		# Fetch rate master enabled
		where_condition = []
		where_condition << "cis_fetch_data = '1'"
		@rate_masters = RateMaster.where("cis_fetch_data = '1' AND cis_fetch_interval <> '' AND cis_fetch_interval IS NOT NULL").group('cis_for_cd, cis_net_cd, cis_service_cd')
		#render plain: @rate_masters.inspect and return
		@check_loop = []
		for master_record in @rate_masters
			last_date 	= Time.now
			date1 	= Time.now.months_ago(1)
			while date1 < last_date  do
				#@check_loop << date1
				date2 = date1 + master_record.cis_fetch_interval.days
				if date2 > last_date
					date2 = last_date
				end
				exclude_data = CisAirwaybill.where("frd = '#{master_record.cis_for_cd}' AND bnet_cd = '#{master_record.cis_net_cd}' AND bservice_cd = '#{master_record.cis_service_cd}' AND booking_date BETWEEN '#{date1.to_date.to_formatted_s(:db)}' AND '#{date2.to_date.to_formatted_s(:db)}' ").pluck(:awb_no)

				# Send CURL req here
				c = Curl::Easy.http_post(APP_CONFIG['cis_fetch_data'],
						Curl::PostField.content('for_cd', master_record.cis_for_cd),
						Curl::PostField.content('net_cd', master_record.cis_net_cd),
						Curl::PostField.content('service_cd', master_record.cis_service_cd),
						Curl::PostField.content('date1', date1.to_date.to_formatted_s(:db)),
						Curl::PostField.content('date2', date2.to_date.to_formatted_s(:db)),
						Curl::PostField.content('exclude', exclude_data.join(",")))
				c.perform
				json = JSON.parse(c.body_str)
				#render plain: json['data'].inspect and return

				json['data'].each do |record|
					#render plain: record.inspect
					begin
					    dely_date = DateTime.parse(record['pod_dt'] + " " + record['pod_tm'])
						#render plain: record.inspect + dely_date.inspect and return
						@cis_awb = CisAirwaybill.new(:net_no => record['net_no'],
												:awb_no => record['awb_no'],
												:frd => master_record.cis_for_cd,
												:bnet_cd => master_record.cis_net_cd,
												:bservice_cd => master_record.cis_service_cd,
												:sec_cd => record['sec_cd'],
												:cln_cd => record['cln_cd'],
												:actual_wt => record['wt'],
												:vol_wt => record['vol_wt'],
												:no_pcs => record['pcs'],
												:booking_date => record['awb_dt'],
												:received_by => record['rcv_by'],
												:delivery_datetime => dely_date.to_formatted_s(:db))
						@cis_awb.save
					rescue
					     render plain: "#{$!}" + record.inspect and return
					end

					
				end
				date1 = date2
			end
			
		end
		render plain: "Not Found" and return
		#render plain: @check_loop.inspect and return
	end

	def fetch_destination_data
		
	end

	def fetch_client_data
		exclude_data = Client.pluck(:cln_cd)

		# Send CURL req here
		c = Curl::Easy.http_post(APP_CONFIG['cis_fetch_clients'],
				Curl::PostField.content('exclude', exclude_data.join(",")))
		c.perform
		json = JSON.parse(c.body_str)
		render plain: json['data'].inspect and return

		json['data'].each do |record|
			#render plain: record.inspect
			begin
			    dely_date = DateTime.parse(record['pod_dt'] + " " + record['pod_tm'])
				#render plain: record.inspect + dely_date.inspect and return
				@cis_awb = CisAirwaybill.new(:net_no => record['net_no'],
										:awb_no => record['awb_no'],
										:frd => master_record.cis_for_cd,
										:bnet_cd => master_record.cis_net_cd,
										:bservice_cd => master_record.cis_service_cd,
										:sec_cd => record['sec_cd'],
										:cln_cd => record['cln_cd'],
										:actual_wt => record['wt'],
										:vol_wt => record['vol_wt'],
										:no_pcs => record['pcs'],
										:booking_date => record['awb_dt'],
										:received_by => record['rcv_by'],
										:delivery_datetime => dely_date.to_formatted_s(:db))
				@cis_awb.save
			rescue
			     render plain: "#{$!}" + record.inspect and return
			end

			
		end
	end
end

