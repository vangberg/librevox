require 'rubygems'
require 'eventmachine'
require 'fsr/listener'
require 'fsr/listener/header_and_content_response.rb'

module FSR
  module Listener
    class Inbound < EventMachine::Protocols::HeaderAndContentProtocol
      HOOKS = {}

      def initialize(args = {})
        super
        @auth = args[:auth] || "ClueCon"
      end

      # post_init is called upon each "new" socket connection
      def post_init
        say("auth #{@auth}")
        say('event plain ALL')
      end

      # receive_request is the callback method when data is recieved from the
      # socket.
      #
      # @param [#each_line] headers
      #   headers from HeaderAndContentProtocol
      # @param [#each_line] content
      #   content from HeaderAndContentProtocol
      def receive_request(headers, content)
        event = HeaderAndContentResponse.from_raw(headers, content)
        event_name = event.event_name

        unless event_name.empty?
          hook = HOOKS[event_name.to_sym]
          hook.call(event) if hook
        end

      ensure
        on_event(event)
      end

      # say encapsulates #send_data for the user
      #
      # param line Line of text to send to the socket
      def say(line)
        send_data("#{line}\r\n\r\n")
      end

      # on_event is the callback method when an event is triggered.
      # It will be triggered even if an hook fails with an exception.
      #
      # param event The triggered event object
      # return event The triggered event object
      def on_event(event)
      end

      # add_event_hook adds an Event to listen for. When that Event is
      # triggered, it will call the defined block
      #
      # @return [Proc, nil] depending on what +&block+ was
      #
      # @param [Symbol, #to_sym] event
      #   The event to trigger the block on.  Examples are :CHANNEL_CREATE,
      #   :CHANNEL_DESTROY, etc
      # @param [Proc] block
      #   The block to execute when the event is triggered
      def self.add_event_hook(event, &block)
        HOOKS[event.to_sym] = block
      end

      # del_event_hook removes an Event.
      #
      # @param event The event to remove.  Examples, :CHANNEL_CREATE, :CHANNEL_DESTROY, etc
      def self.del_event_hook(event)
        HOOKS.delete(event.to_sym)
      end

    end

  end
end
