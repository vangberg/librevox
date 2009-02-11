require 'lib/event_socket'

module FreeSwitcher
  class InboundEventSocket < EventSocket 

    def initialize(args = {})
      @server = args[:server] || "127.0.0.1"
      @port = args[:port] || "8021"
      @auth = args[:auth] || "ClueCon"
      @socket = TCPSocket.new(@server, @port)
      super(@socket)
      unless login
        raise "Unable to login, check your password!"
      end
    end
  
    def login
      return_result
      self << "auth #{@auth}"
      return_result
    end
  end
end
