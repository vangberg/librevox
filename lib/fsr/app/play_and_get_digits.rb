require "fsr/app"
module FSR
  #http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_play_and_get_digits
  module App
    class PlayAndGetDigits < Application
      def self.app_name
        "play_and_get_digits"
      end

      attr_reader :read_channel_var
      DEFAULT_ARGS = {:min => 0, :max => 10, :tries => 3, :timeout => 7000, :terminators => ["#"], :chan_var => "fsr_read_dtmf", :regexp => '\d'}

      # args format for array:
      # sound_file, invalid_file, min = 0, max = 10, tries = 3, timeout = 7000, terminators = ["#"], chan_var = "fsr_read_dtmf", regexp = '\d'
      def initialize(sound_file, invalid_file, *args)
        #puts args.inspect
        if args.size == 1 and args.first.kind_of?(Hash)
          arg_hash = DEFAULT_ARGS.merge(args.first)
        elsif args.size > 0
          # The array used to .zip the args here can be replaced with DEFAULT_ARGS.keys if Hash keys are ordered (1.9)
          # For now we'll hard code them to preserve order in 1.8/jruby
          arg_hash = DEFAULT_ARGS.merge(Hash[[:min, :max, :tries, :timeout, :terminators, :chan_var, :regexp][0 .. (args.size-1)].zip(args)]) 
        elsif args.size == 0
          arg_hash = DEFAULT_ARGS
        else
          raise "Invalid Arguments for PlayAndGetDigits#new (must pass (sound_file, invalid_file, hash) or (sound_file, invalid_file, min = 0, max = 10, tries = 3, timeout = 7000, terminators = ['#'], chan_var = 'fsr_read_dtmf', regexp = '\d'))"
        end
        @sound_file = sound_file
        @invalid_file = invalid_file
        @min = arg_hash[:min]
        @max = arg_hash[:max]
        @tries = arg_hash[:tries]
        @timeout = arg_hash[:timeout]
        @read_channel_var = arg_hash[:chan_var]
        @terminators = arg_hash[:terminators]
        @regexp = arg_hash[:regexp]
      end

      def arguments
        [@min, @max, @tries, @timeout, @terminators.join(","), @sound_file, @invalid_file, @read_channel_var, @regexp]
      end

      def event_lock
        true
      end
    end

    register PlayAndGetDigits
  end
end
