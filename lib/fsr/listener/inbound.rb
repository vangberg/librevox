require 'rubygems'
require 'eventmachine'
require 'fsr/listener'
require 'fsr/listener/header_and_content_response'

module FSR
  module Listener
    class Inbound < EventMachine::Protocols::HeaderAndContentProtocol

      def initialize(args = {})
        super
        @auth = args[:auth] || "ClueCon"
      end

      def post_init
        say("auth #{@auth}")
        say('event plain ALL')
      end

      def receive_request(header, content)
        hash_header = headers_2_hash(header)
        hash_content = headers_2_hash(content)
        event = HeaderAndContentResponse.new({:headers => hash_header, :content => hash_content})
        on_event(event)
      end
   
      def say(line)
        send_data("#{line}\r\n\r\n")
      end

      def on_event(event)
        event
      end

    end
  end
end
