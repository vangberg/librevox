require "fsr/app"
module FSR
  #http://wiki.freeswitch.org/wiki/Mod_commands#uuid_setvar
  module App
    class UuidSetVar < Application
      def initialize(uuid, var, assignment)
        @uuid = uuid # Unique channel ID
        @var = var # Channel variable you wish to 'set'
        @assignment
      end

      def arguments
        [@uuid, @var, @assignment]
      end

      def sendmsg
        "call-command: execute\nexecute-app-name: %s\nexecute-app-arg: %s\nevent-lock:true\n\n" % [app_name, arguments.join(" ")]
      end

    end

    register(:uuid_setvar, UuidSetVar)
  end
end
