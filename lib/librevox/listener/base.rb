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

      # In some cases there are both applications and commands with the same
      # name, e.g. fifo. But we can't have two `fifo`-methods, so we include
      # commands in CommandDelegate, and wrap all commands in the `api` call,
      # which forwards the call to the CommandDelegate instance, which in turn
      # forwards the #run_cmd-call from the command back to the listener. Yay.
      class CommandDelegate
        include Librevox::Commands

        def initialize(listener)
          @listener = listener
        end

        def run_cmd(*args, &block)
          @listener.run_cmd *args, &block
        end
      end

      def api(cmd, *args, &block)
        @command_delegate.send(cmd, *args, &block)
      end

      def run_cmd(cmd, &block)
        send_data "#{cmd}\n\n"
        @api_queue << (block || lambda {})
      end

      attr_accessor :response
      alias :event :response

      def post_init
        @command_delegate = CommandDelegate.new(self)
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
