require "fsr/app"
module FSR
  module Cmd
    class Sofia 
      class Profile < Command
        attr_reader :fs_socket, :raw_string

        def initialize(fs_socket = nil, args = nil)
          @fs_socket = fs_socket # FSR::CommandSocket object
          @raw_string = args # If user wants to send a raw "sofia profile"
        end

        # Send the command to the event socket, using api by default.
        def run(api_method = :api)
          orig_command = "%s %s" % [api_method, raw]
          Log.debug "saying #{orig_command}"
          @fs_socket.say(orig_command)
        end

        # Start a sip_profile
        def start(profile)
          require 'fsr/cmd/sofia/profile/start'
          Profile::Start.new(@fs_socket, profile)
        end

        # Restart a sip_profile
        def restart(profile)
          require 'fsr/cmd/sofia/profile/restart'
          Profile::Restart.new(@fs_socket, profile)
        end

        # Stop a sip_profile
        def stop(profile)
          require 'fsr/cmd/sofia/profile/stop'
          Profile::Stop.new(@fs_socket, profile)
        end

        # Rescan a sip_profile
        def rescan(profile)
          require 'fsr/cmd/sofia/profile/rescan'
          Profile::Rescan.new(@fs_socket, profile)
        end


        # This method builds the API command to send to the freeswitch event socket
        def raw
          unless @raw_string.nil? or @raw_string.empty?
            orig_command = "sofia profile #{@raw_string}"
          else
            orig_command = "sofia profile"
          end
        end
      end
    end
  end
end
