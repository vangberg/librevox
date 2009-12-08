
require "fsr/app"
module FSR
  module App
    class FSBreak < Application
      def self.app_name
        "fs_break"
      end

      def initialize
      end

      def arguments
        []
      end

      def sendmsg
        "call-command: execute\nexecute-app-name: break\n\n"
      end

    end

    register FSBreak
  end
end
