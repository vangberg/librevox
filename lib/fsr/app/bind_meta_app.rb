
require "fsr/app"
module FSR
  module App
    class BindMetaApp < Application
      def self.app_name
        "bind_meta_app"
      end

      attr_reader :options

      def initialize(args)
        @options = args
      end

      def arguments
        parameters = options[:parameters] ? "::#{options[:parameters]}" : ""
        [options[:key], options[:listen_to], options[:respond_on], options[:application] + parameters]
      end
    end

    register BindMetaApp
  end
end
