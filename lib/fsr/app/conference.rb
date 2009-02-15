
require "fsr/app"
module FSR
  module App
    class Conference < Application
      attr_reader :target, :profile

      def initialize(conference_name, conference_profile = "ultrawideband")
        # These are options that will precede the target address
        @target = conference_name
        @profile = conference_profile
      end

      # This method builds the API command to send to freeswitch
      def raw
        "conference(#{@target}@#{@profile})"
      end

      def self.execute(target, opts = {})
        self.new(target, opts).raw
      end
    end

    register(:conference, Conference)
  end
end
