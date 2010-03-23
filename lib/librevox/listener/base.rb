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
      # commands in CommandDelegate, and expose all commands through the `api`
      # method, which wraps a CommandDelegate instance.
      class CommandDelegate
        include Librevox::Commands

        def initialize listener
          @listener = listener
        end

        def command *args, &block
          @listener.command super(*args), &block
        end
      end

      # Exposes an instance of {CommandDelegate}, which includes {Librevox::Commands}.
      # @example
      #   api.status
      #   api.fsctl :pause
      #   api.uuid_park "592567a2-1be4-11df-a036-19bfdab2092f"
      # @see Librevox::Commands
      def api
        @command_delegate ||= CommandDelegate.new(self)
      end

      def command msg
        send_data "#{msg}\n\n"

        @command_queue << Fiber.current
        Fiber.yield
      end

      attr_accessor :response
      alias :event :response

      def post_init
        @command_queue = []
      end

      def receive_request header, content
        @response = Librevox::Response.new(header, content)
        handle_response
      end

      def handle_response
        if response.api_response? && @command_queue.any?
          #invoke_command_queue
          @command_queue.shift.resume response
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
            Fiber.new {
              instance_exec response.dup, &block 
            }.resume
          end
        }
      end

      def invoke_command_queue
        block = @command_queue.shift
        if block.arity == 0
          block.call
        else
          block.call response
        end
      end
    end
  end
end
