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
				
			end
		end
		
		def start_listener
		
		end
	end
end