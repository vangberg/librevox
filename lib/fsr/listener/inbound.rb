require 'rubygems'
require 'eventmachine'
require 'fsr/listener'
require 'fsr/listener/header_and_content_response.rb'

module FSR
  module Listener
    class Inbound < EventMachine::Protocols::HeaderAndContentProtocol
      attr_reader :auth, :hooks, :event, :server, :port

      HOOKS = {}

      def initialize(args = {})
        super
        @auth = args[:auth] || "ClueCon"
        @host = args[:host]
        @port = args[:port]
        @hooks = {}
      end

      # post_init is called upon each "new" socket connection.
      #
      # If Freeswitcher hasn't started listening for inbound socket connections
      # yet, EventMachine will silently do nothing. A periodic timer is added
      # to check wether the connection has been initiated yet, otherwise tries
      # again in five seconds.
      def post_init
        if error?
          reconnect_until_succeeding
        else
          authorize_and_register_for_events
        end
      end

      def reconnect_until_succeeding
        timer = EM::PeriodicTimer.new(5) {
          if error?
            FSR::Log.info "Couldn't establish connection. Trying again…"
           reconnect @host, @port
          else
            timer.cancel
            authorize_and_register_for_events
          end
        }
      end

      def authorize_and_register_for_events
        FSR::Log.info "Connection established. Authorizing…"
        say("auth #{@auth}")
        say('event plain ALL')
      end

      def before_session 
      end

      # receive_request is the callback method when data is recieved from the socket
      #
      # param header headers from standard Header and Content protocol
      # param content content from standard Header and Content protocol
      def receive_request(header, content)
        hash_header = headers_2_hash(header)
        hash_content = headers_2_hash(content)
        @event = HeaderAndContentResponse.new({:headers => hash_header, :content => hash_content})
        event_name = event.content[:event_name].to_s.strip
        unless event_name.empty?
          instance_eval &HOOKS[event_name.to_sym] unless HOOKS[event_name.to_sym].nil?
          instance_eval &@hooks[event_name.to_sym] unless @hooks[event_name.to_sym].nil?
        end
        on_event
      end

      # say encapsulates #send_data for the user
      #
      # param line Line of text to send to the socket
      def say(line)
        send_data("#{line}\r\n\r\n")
      end

      # api encapsulates #say("api blah") for the user
      #
      # param line Line of text to send to the socket proceeding api
      def api(line)
        say("api #{line}")
      end
      
      # on_event is the callback method when an event is triggered
      #
      # param event The triggered event object
      # return event The triggered event object
      def on_event
        event
      end

      # add_event_hook adds an Event to listen for.  When that Event is triggered, it will call the defined block
      #
      # @param event The event to trigger the block on.  Examples, :CHANNEL_CREATE, :CHANNEL_DESTROY, etc
      # @param block The block to execute when the event is triggered
      def self.add_event_hook(event, &block)
        HOOKS[event] = block 
      end

      # del_event_hook removes an Event.
      #
      # @param event The event to remove.  Examples, :CHANNEL_CREATE, :CHANNEL_DESTROY, etc
      def self.del_event_hook(event)
        HOOKS.delete(event)  
      end

      # add_event_hook adds an Event to listen for.  When that Event is triggered, it will call the defined block
      #
      # @param event The event to trigger the block on.  Examples, :CHANNEL_CREATE, :CHANNEL_DESTROY, etc
      # @param block The block to execute when the event is triggered
      def add_event(event, &block)
        @hooks[event] = block 
      end

      # del_event_hook removes an Event.
      #
      # @param event The event to remove.  Examples, :CHANNEL_CREATE, :CHANNEL_DESTROY, etc
      def del_event(event)
        @hooks.delete(event)  
      end



    end

  end
end
