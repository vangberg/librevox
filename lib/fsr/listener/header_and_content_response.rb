require 'fsr/listener'

module FSR
  module Listener
    class HeaderAndContentResponse

      attr_reader :headers, :content

      def initialize(args = {})
        @headers = args[:headers]
        @content =  args[:content]
      end
      
      # Keep backward compat with the other 2 people who use FSR
      def body
        @content
      end

    end
  end
end
