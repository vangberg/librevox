require "fsr/app"
module FSR
  module App
    class Playback < Application
      attr_reader :wavfile

      def initialize(wavfile)
        # wav file you wish to play, full path 
        @wavfile = wavfile
      end
      def arguments
        [@wavfile]
      end

    end

    register(:playback, Playback)
  end
end
