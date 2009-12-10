require 'eventmachine'
require 'fsr/response'

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

      def post_init
        @api_queue = []
      end

      def receive_request(header, content)
        @response = Response.new(header, content)

        if response.event?
          on_event
          find_and_invoke_event response.event
        elsif response.api_response? && @api_queue.any?
          block = @api_queue.shift
          block.arity == 1 ? block.call(response.content) : block.call
        end
      end

      def api(command, *args, &block)
        msg = "api #{command} #{args.join(" ")}".chomp(" ")
        send_data "#{msg}\n\n"
        @api_queue << (block_given? ? block : lambda {})
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
