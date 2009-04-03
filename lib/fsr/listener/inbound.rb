require 'rubygems'
require 'eventmachine'
require 'fsr/listener'
require 'fsr/listener/inbound/event.rb'

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
        event_name = event.content[:event_name].to_s.strip
        unless event_name.empty?
          HOOKS[event_name.to_sym].call(event) unless HOOKS[event_name.to_sym].nil?
        end
        on_event(event)
      end

      def say(line)
        send_data("#{line}\r\n\r\n")
      end

      def on_event(event)
        event
      end

      # Add or replace a block to execute when the specified event occurs
      #
      # <b>Parameters</b>
      # - event             : What event to trigger the block on. May be
      #                       :CHANNEL_CREATE, :CHANNEL_DESTROY etc
      # - block             : Block to execute
      #
      # <b>Returns/<b>
      # - nil
      def self.add_event_hook(event, &block)
        HOOKS[event] = block 
      end

      # Delete the block that was to be executed for the specified event.
      def self.del_event_hook(event)
        HOOKS.delete(event)  
      end

    end

#    module Inbound 
#      include FSR::Listener
#      HOOKS = {}
#      def post_init
#        say('auth ClueCon')
#        say('event plain ALL')
#      end
#      def receive_data(data)
#        event = Event.from(data)
#        event_name = event["Event-Name"].to_s
#        unless event_name.empty?
#          HOOKS[event_name.to_sym].call(event) unless HOOKS[event_name.to_sym].nil?
#        end
#        on_event(event)
#      end
#      def say(line)
#        send_data("#{line}\n\n")
#      end
#      def on_event(event)
#        event
#      end
#      # Add or replace a block to execute when the specified event occurs
#      #
#      # <b>Parameters</b>
#      # - event             : What event to trigger the block on. May be
#      #                       :CHANNEL_CREATE, :CHANNEL_DESTROY etc
#      # - block             : Block to execute
#      #
#      # <b>Returns/<b>
#      # - nil
#      def self.add_event_hook(event, &block)
#        HOOKS[event] = block
#      end
#      # Delete the block that was to be executed for the specified event.
#      def self.del_event_hook(event)
#        HOOKS.delete(event)
#      end
#
#    end

  end
end
