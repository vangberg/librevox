require "fsr/app"
module FSR
  module App
    class Playback < Application
      def initialize(file)
        @file = file
      end

      def arguments
        [@file]
      end

      def event_lock
        true
      end
    end

    register Playback
  end
end
