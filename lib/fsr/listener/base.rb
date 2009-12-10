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
      alias :event :response

      def receive_request(header, content)
        @response = Response.new(header, content)

        if response.event?
          on_event
          find_and_invoke_event response.event
        end
      end

      # override
      def on_event
      end

      private
      def find_and_invoke_event(event_name)
        self.class.hooks.each do |name,block| 
          instance_eval(&block) if name == event_name.to_sym
        end
      end
    end
  end
end
