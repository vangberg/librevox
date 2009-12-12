require "fsr/app"
module FSR
  module App
    # http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_hangup
    class Hangup < Application
      attr_reader :arguments

      def initialize(cause=nil)
        @arguments = [cause]
      end
    end

    register Hangup
  end
end
