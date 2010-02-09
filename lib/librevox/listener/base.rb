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

        def event event, &block
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

        def initialize listener
          @listener = listener
        end

        def run_cmd *args, &block
          @listener.run_cmd *args, &block
        end
      end

      def api cmd, *args, &block
        @command_delegate.send(cmd, *args, &block)
      end

      def run_cmd cmd, &block
        send_data "#{cmd}\n\n"
        @command_queue << (block || lambda {})
      end

      attr_accessor :response
      alias :event :response

      def post_init
        @command_delegate = CommandDelegate.new(self)
        @command_queue = []
      end

      def receive_request header, content
        @response = Librevox::Response.new(header, content)
        handle_response
      end

      def handle_response
        if response.api_response? && @command_queue.any?
          invoke_command_queue
        elsif response.event?
          on_event response.dup
          invoke_event_hooks
        end
      end

      # override
      def on_event event
      end

      alias :done :close_connection_after_writing

      private
      def invoke_event_hooks
        self.class.hooks.each {|name,block| 
          if name == response.event.downcase.to_sym
            instance_exec response.dup, &block 
          end
        }
      end

      def invoke_command_queue
        block = @command_queue.shift
        block.call response
      end
    end
  end
end
