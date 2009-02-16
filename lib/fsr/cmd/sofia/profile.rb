require "fsr/app"
module FSR
  module Cmd
    class Sofia 
      class Profile < Command
        attr_reader :fs_socket

        def initialize(fs_socket = nil, args = {})
          @fs_socket = fs_socket # FSR::CommandSocket object
          if args.class == Hash
            @profile = args[:profile] # Name of profile
            @exec = args[:exec] # Command to execute on profile
          elsif args.class == String
            @raw_string = args
          end
        end

        # Send the command to the event socket, using api by default.
        def run(api_method = :api)
          orig_command = "%s %s" % [api_method, raw]
          Log.debug "saying #{orig_command}"
          @fs_socket.say(orig_command)
        end

        # This method builds the API command to send to the freeswitch event socket
        def raw
          if @profile and @exec
            orig_command = "sofia profile #{@profile} #{@exec}"
          elsif @raw_string
            orig_command = "sofia profile #{@raw_string}"
          else
            orig_command = "sofia profile"
          end
        end
      end
    end
  end
end
