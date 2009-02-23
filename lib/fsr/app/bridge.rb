
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

      def arguments
        [@target]
      end

      def modifiers
        @options.map { |k,v| "%s=%s" % [k, v] }.join(",")
      end

      def raw
        "%s({%s}%s)" % [app_name, modifiers, arguments.join(" ")]
      end

      def self.execute(target, opts = {})
        self.new(target, opts).raw
      end
    end

    register(:bridge, Bridge)
  end
end
