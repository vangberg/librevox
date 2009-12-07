
require "fsr/app"
module FSR
  module App
    class Bridge < Application
      def initialize(*params)
        @options = params.last.is_a?(Hash) ? params.pop : {}
        @sequential = @options.delete(:sequential)
        @targets = params
      end

      def arguments
        delimeter = @sequential ? "|" : ","
        [@targets.join(delimeter)]
      end

      def modifiers
        @options.map { |k,v| "%s=%s" % [k, v] }.join(",")
      end

      def raw
        "%s({%s}%s)" % [app_name, modifiers, arguments.join(" ")]
      end
    end

    register Bridge
  end
end
