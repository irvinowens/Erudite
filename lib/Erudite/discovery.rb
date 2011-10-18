require "socket"

module Disco
	class Cluster
		
		attr_accessor :ping_thread, :ip_address
	
		def initialize
			start_pings
			#@ping_thread = Thread.new do
			#	start_pings
			#end
		end
		
		def start_pings
			puts "Hostname #{Socket.ip_address_list}"
			@ip_address = Socket.ip_address_list
			@ip_address.each do |ip_addr|
				if ip_addr.ip?
					if ip_addr.ipv4?
						if ip_addr.ipv4_loopback? == false
							if ip_addr.ipv4_private? == true
								puts "private address #{ip_addr.ip_address}"
								check_range_for_ip_address ip_addr
							end
						end
					end
				end
			end
		end
		
		def start_listener
		
		end
		
		def check_range_for_ip_address ip
		
		end
	end
end