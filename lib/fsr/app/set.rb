require "fsr/app"
module FSR
  module App
    class Set < Application
      attr_reader :data

      def initialize(data)
        # We might consider the first arg to be the variable name and the second
        # the value?
        @data = data
      end
      def arguments
        @data
      end

      def sendmsg
        "call-command: execute\nexecute-app-name: %s\nexecute-app-arg: %s\nevent-lock:true\n\n" % [app_name, arguments] 
      end
    end

    register(:set, Set)
  end
end
