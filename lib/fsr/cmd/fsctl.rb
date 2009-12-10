# A lot of methods are missing here. The only one implemented is max_sessions
# The max_sessions getter currently returns the raw result but could instead return an Integer

require "fsr/app"
module FSR
  module Cmd
    class Fsctl < Command
      attr_reader :command

      # Get max sessions
      def max_sessions
        @command = "max_sessions"
        run
      end

      # Set max sessions
      def max_sessions=(sessions)
        @command = "max_sessions #{sessions}"
        run
      end
    
      # This method builds the API command to send to the freeswitch event socket
      def raw
        orig_command = "api fsctl #{@command}"
      end
    end

  register Fsctl
  end
end
