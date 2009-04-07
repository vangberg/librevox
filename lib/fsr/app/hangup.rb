require "fsr/app"
module FSR
  module App
    # http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_hangup
    class Hangup < Application
      def initialize(data = nil)
        @data = data
      end

      def arguments
        @data
      end

      def sendmsg
        "call-command: execute\nexecute-app-name: %s\nexecute-app-arg: %s\n\n" % [app_name, arguments]
      end

    end

    register(:hangup, Hangup)
  end
end
