require "fsr/app"
module FSR
  module Cmd
    class Limit < Command

      def initialize(fs_socket = nil, id = nil, realm = "$${domain}", limit = 5)
        @fs_socket = fs_socket # FSR::CommandSocket obj
        @realm, @id, @limit = realm, id, limit
        raise "Must supply a valid id" if @id.nil?
      end

      # Send the command to the event socket, using bgapi by default.
      def run(api_method = :api)
        orig_command = "%s %s" % [api_method, raw]
        Log.debug "saying #{orig_command}"
        @fs_socket.say(orig_command)
      end

      def arguments
        [@realm, @id, @limit]
      end

      # This method builds the API command to send to the freeswitch event socket
      def raw
        orig_command = "limit %s %s %s" % arguments
      end
    end

    register(:limit, Limit)
  end
end
