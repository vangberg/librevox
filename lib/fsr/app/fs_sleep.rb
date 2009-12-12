
require "fsr/app"
module FSR
  module App
    class FSSleep < Application
      def self.app_name
        "sleep"
      end

      attr_reader :arguments

      def initialize(msec)
        @arguments = [msec]
      end
    end

    register FSSleep
  end
end
