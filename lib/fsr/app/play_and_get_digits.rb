require "fsr/app"
module FSR
  #http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_play_and_get_digits
  module App
    class PlayAndGetDigits < Application
      def initialize(sound_file, invalid_file, min = 0, max = 10, tries = 3, timeout = 7000, terminators = ["#"], chan_var = "fsr_read_dtmf", regexp = "\d")
        @sound_file = sound_file
        @invalid_file = invalid_file
        @min = min
        @max = max
        @tries = tries
        @timeout = timeout
        @chan_var = chan_var
        @terminators = terminators
        @regexp = regexp
      end

      def arguments
        [@min, @max, @tries, @timeout, @terminators.join(","), @sound_file, @invalid_file, @chan_var, @regexp]
      end

      def sendmsg
        "call-command: execute\nexecute-app-name: %s\nexecute-app-arg: %s\nevent-lock:true\n\n" % ["play_and_get_digits", arguments.join(" ")]
      end

    end

    register(:play_and_get_digits, PlayAndGetDigits)
  end
end
