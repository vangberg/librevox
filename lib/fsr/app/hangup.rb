require "fsr/app"
module FSR
  module App
    # http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_hangup
    class Hangup < Application
      def initialize(cause=nil)
        @cause = cause
      end

      def arguments
        [@cause]
      end
    end

    register Hangup
  end
end
