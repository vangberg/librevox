require "fsr/app"
module FSR
  #http://wiki.freeswitch.org/wiki/Mod_commands#uuid_getvar
  module App
    class UuidGetVar < Application
      def initialize(uuid, var)
        @uuid = uuid # Unique channel ID
        @var = var # Channel variable you wish to 'get'
      end

      def arguments
        [@uuid, @var]
      end

      def sendmsg
        "call-command: execute\nexecute-app-name: %s\nexecute-app-arg: %s\nevent-lock:true\n\n" % [app_name, arguments.join(" ")]
      end

    end

    register(:uuid_getvar, UuidGetVar)
  end
end
