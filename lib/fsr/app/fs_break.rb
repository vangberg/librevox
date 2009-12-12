
require "fsr/app"
module FSR
  module App
    class FSBreak < Application
      def self.app_name
        "break"
      end

      attr_reader :arguments

      def initialize(args={})
        @arguments = []
        @arguments << "all" if args[:all]
      end
    end

    register FSBreak
  end
end
