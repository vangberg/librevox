require "fsr/app"
module FSR
    # http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_read
  module App
    class Read < Application
      attr_reader :read_channel_var

      def initialize(sound_file, min = 0, max = 10, chan_var = "fsr_read_dtmf", timeout = 10000, terminators = ["#"])
        @sound_file, @min, @max, @read_channel_var, @timeout, @terminators = sound_file, min, max, chan_var, timeout, terminators
      end

      def arguments
        [@min, @max, @sound_file, @read_channel_var, @timeout, @terminators.join(",")]
      end
    end
    register Read


  end
end
