require 'eventmachine'
require 'librevox/response'
require 'librevox/commands'

module Librevox
  module Listener
    class Base < EventMachine::Protocols::HeaderAndContentProtocol
      class << self
        def hooks
          @hooks ||= []
        end

        def event(event, &block)
          hooks << [event, block]
        end
      end

      include Librevox::Commands

      def run_cmd(cmd, &block)
        send_data "#{cmd}\n\n"
        @api_queue << (block_given? ? block : lambda {})
      end

      attr_accessor :response
      alias :event :response

      def post_init
        @api_queue = []
      end

      def receive_request(header, content)
        @response = Librevox::Response.new(header, content)

        if response.event?
          on_event
          invoke_event response.event
        elsif response.api_response? && @api_queue.any?
          invoke_api_queue
        end
      end

      # override
      def on_event
      end

      private
      def invoke_event(event_name)
        self.class.hooks.each do |name,block| 
          instance_eval(&block) if name == event_name.downcase.to_sym
        end
      end

      def invoke_api_queue
        block = @api_queue.shift
        block.call(response)
      end
    end
  end
end
