require 'fsr/listener'

module FSR
  module Listener
    class HeaderAndContentResponse

      attr_reader :headers, :content

      def initialize(args = {})
        @headers = args[:headers]
        @content = args[:content]
        strip_newlines
      end

      def strip_newlines
        @content.each {|k,v| v.chomp! if v.is_a?(String)}
      end
    end
  end
end
