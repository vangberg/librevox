
require "fsr/app"
module FSR
  module App
    class Bridge < Application
      attr_reader :options

      def initialize(target, opts = {})
        # These are options that will precede the target address
        @target = target
        @options = opts || {}
      end

      # This method builds the API command to send to freeswitch
      def raw
        opts = @options.map { |k,v| "%s=%s" % [k, v] }.join(",")
        "bridge({#{opts}}#{@target})"
      end

      def arguments
        [@target]
      end

      def modifiers
        @options.map { |k,v| "%s=%s" % [k, v] }.join(",")
      end

      def app_name
        self.class.name.split("::").last.downcase
      end

      def raw
        "%s({%s}%s)" % [app_name, modifiers, arguments.join(" ")]
      end

      def sendmsg
        "call-command: execute\nexecute-app-name: %s\nexecute-app-arg: %s\n\n" % [app_name, arguments.join(" ")]
      end

      def self.execute(target, opts = {})
        self.new(target, opts).raw
      end
    end

    register(:bridge, Bridge)
  end
end
