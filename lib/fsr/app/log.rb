require "fsr/app"
module FSR
  module App
    # http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_log
    class Log < Application
      def initialize(level=1, text="")
        @level = level
        @text = text
      end

      def arguments
        [@level, @text]
      end
      
      def event_lock
        true
      end
    end

    register Log
  end
end
