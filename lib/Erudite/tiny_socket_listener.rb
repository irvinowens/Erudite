require 'uuid.rb'

# tiny_socket_listener.rb
# A really small socket listener class to be added to another class

class TinySocketListener

	:attr_accessor fibers, handler

	def initialize
		@fibers = Hash.new
		@handler = nil
	end
	
	# The parameter should be a ruby hash 
	# with listener port :port, :handler
	
	def start_listening(h)
		port = h[:port] || 13373
		handler = h[:port] || nil
		@handler = SimpleDelegator.new(handler)
		Socket.tcp_server_loop(port) do |sock, client_addrinfo|
			fiber = Fiber.new do
				begin
					process_sock sock
				ensure
					sock.close();
				end
			end
			@fibers[UUID.new.to_s, fiber]
		end
	end
	
	def process_sock sock
		@handler.process sock
	end
end