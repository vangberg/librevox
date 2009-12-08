require "fsr/app"
module FSR
  #http://wiki.freeswitch.org/wiki/Mod_commands#uuid_dump
  module App
    class UuidDump < Application
      def self.app_name
        "uuid_dump"
      end

      def initialize(uuid)
        @uuid = uuid # Unique channel ID
      end

      def arguments
        [@uuid]
      end

      def sendmsg
        "call-command: execute\nexecute-app-name: %s\nexecute-app-arg: %s\nevent-lock:true\n\n" % [app_name, arguments.join(" ")]
      end

    end

    register UuidDump
  end
end
