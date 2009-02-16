
require "fsr/app"
module FSR
  module App
    class Fifo < Application
      attr_accessor :name, :direction
      attr_reader :options

      def self.<<(name)
        new(name)
      end

      def self.>>(name)
        new(name, "out", :wait => false)
      end

      def initialize(name, direction = nil, options = nil)
        # These are options that will precede the target address
        @name = name
        @direction = direction || "in"
        raise "Direction must be 'in' or 'out'" unless @direction.match(/^(?:in|out)$/)
        @options = options || {}
        raise "options must be a hash" unless @options.kind_of?(Hash)
      end

      # This method builds the API command to send to freeswitch
      def raw
        if @direction == "out"
          options[:wait] = options[:wait] ? "wait" : "nowait"
          "fifo(#{name} out #{options[:wait]})"
        else
          "fifo(#{name} in)"
        end
      end

    end

    register(:fifo, Fifo)
  end
end
