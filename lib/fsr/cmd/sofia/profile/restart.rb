require "fsr/app"
module FSR
  module Cmd
    class Sofia 
      class Profile
        class Restart < Command
          attr_reader :fs_socket, :profile

          def initialize(fs_socket = nil, profile = nil)
            @fs_socket = fs_socket # FSR::CommandSocket object
            @profile = profile # name of sip profile 
            raise "Must provide name of profile" unless @profile
          end

          # Send the command to the event socket, using api by default.
          def run(api_method = :api)
            orig_command = "%s %s" % [api_method, raw]
            Log.debug "saying #{orig_command}"
            @fs_socket.say(orig_command)
          end

          # This method builds the API command to send to the freeswitch event socket
          def raw
            orig_command = "sofia profile #{@profile} restart"
          end
        end
      end
    end
  end
end
