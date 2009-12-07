require 'eventmachine'
require 'fsr/listener/response'

module FSR
  module Listener
    # Stupid name. I know.
    class Base < EventMachine::Protocols::HeaderAndContentProtocol
      class << self
        def hooks
          @hooks ||= []
        end

        def add_event_hook(event, &block)
          hooks << [event, block]
        end
      end

      attr_accessor :response

      def receive_request(header, content)
        @response = Response.new(header, content)

        if @response.event?
          find_and_invoke_event @response.content[:event_name]
        end
      end

      private
      def find_and_invoke_event(event_name)
        hooks = self.class.hooks.select {|name,_| name == event_name.to_sym}
        hooks.each {|_,block| instance_eval(&block)}
      end
    end
  end
end
