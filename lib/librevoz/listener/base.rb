require 'eventmachine'
require 'librevoz/response'
require 'librevoz/commands'

module Librevoz::Listener
  class Base < EventMachine::Protocols::HeaderAndContentProtocol
    include Librevoz::Commands
    class << self
      def hooks
        @hooks ||= []
      end

      def add_event_hook(event, &block)
        hooks << [event, block]
      end
    end

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
      @response = Librevoz::Response.new(header, content)

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
      block = @api_queue.shift
      block.call(response)
    end
  end
end
