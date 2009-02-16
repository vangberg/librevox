require "fsr/app"
module FSR
  module Cmd
    class Sofia < Command
      attr_reader :fs_socket

      def initialize(fs_socket = nil, args = {})
        @fs_socket = fs_socket # FSR::CommandSocket object
        @status  = args[:status] # Status type; profile or gateway

        # If status is given, make sure it's profile or gateway
        unless @status.nil?
          raise "status must be profile or gateway" unless @status =~ /profile|gateway/i
        end

        @name = args[:name] # Name of profile or gateway
      end

      # Send the command to the event socket, using bgapi by default.
      def run(api_method = :api)
        orig_command = "%s %s" % [api_method, raw]
        Log.debug "saying #{orig_command}"
        @fs_socket.say(orig_command)
      end

      # This method builds the API command to send to the freeswitch event socket
      def raw
        if @status and @name
          orig_command = "sofia status #{@status} #{@name}"
        else
          raise "Usage <status> <name> - <status> is profile or gateway.  <name> is name of profile or gateway."
        end
      end
    end

    register(:sofia, Sofia) 
  end
end
