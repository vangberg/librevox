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

        def register_cmd(klass)
          class_eval <<-EOF
            def #{klass.cmd_name}(*args, &block)
              run_cmd(#{klass}, *args, &block)
            end
          EOF
        end
      end

      def run_cmd(klass, *args, &block)
        cmd = klass.new(*args)
        send_data "#{cmd.raw}\n\n"
        @api_queue << [cmd, (block_given? ? block : lambda {})]
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
          invoke_api_queue
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

      def invoke_api_queue
        cmd, block = @api_queue.shift
        if block.arity == 1 
          cmd.response = response
          block.call(cmd.response)
        else
          block.call
        end
      end
    end
  end
end
