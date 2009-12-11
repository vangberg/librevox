require "fsr/app"
module FSR
  module Cmd
    class Originate < Command
      attr_reader :url, :extension

      def initialize(call_url, ext, vars=nil)
        @url, @extension, @variables = call_url, ext, vars
      end

      def url
        variables ? "{#{variables.join(',')}}#{@url}" : @url
      end

      def variables
        @variables.map {|k,v| "#{k}=#{v}"} if @variables
      end

      def arguments
        [url, extension]
      end
    end

    register Originate
  end
end
