
module FreeSwitcher
  require File.join(File.dirname(__FILE__), 'event_socket') unless FreeSwitcher.const_defined?("EventSocket")

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
      response #Clear buf from initial socket creation/opening 
      self << "auth #{@auth}"
      response #Return response, clear buf for rest of commands
    end
  end
end
