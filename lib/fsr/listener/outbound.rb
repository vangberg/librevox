require "yaml"
require "fsr/listener"
module FSR
  load_all_applications
  module Listener
    module Outbound
      include FSR::Listener

      # Include FSR::App to get all the applications defined as methods
      include FSR::App

      # Redefine the FSR::App methods to wrap sendmsg around them
      SENDMSG_METHOD_DEFINITION = "def %s(*args, &block); sendmsg super; end"
      APPLICATIONS.each { |app, obj| module_eval(SENDMSG_METHOD_DEFINITION % app.to_s) }

      def post_init
        @session = nil # holds the session object
        send_data("connect\n\n")
        FSR::Log.debug "Accepting connections."
      end

      # Received data dispatches the data received by the EM socket,
      # Either as a Session, a continuation of a Session, or as a CommandReply
      def receive_data(data)
        FSR::Log.debug("received #{data}")
        if @session.nil? # If session_collected is true, no need to call our on_call hook.  We only want to execute once per call right?
          @session = Session.new(data)
          session_initiated(@session) if @session.initiated?
        else
          @session.initiated? ? reply_received(CommandReply.new(data)) : @session << data
        end
      end

      def session_initiated(session)
        session
      end

      alias :on_call :session_initiated

      def reply_received(command_reply)
        command_reply
      end

      alias :receive_response :reply_received
      # sendmsg sends data to the EM app socket via #send_data, or
      # returns the string it would send if #send_data is not defined.
      # It expects an object which responds to either #sendmsg or #to_s, 
      # which should return a EM Outbound Event Socket formatted instruction
      def sendmsg(message)
        text = message.respond_to?(:sendmsg) ? message.sendmsg : message.to_s
        FSR::Log.debug "sending #{text}"
        message = "sendmsg\n%s\n" % text
        self.respond_to?(:send_data) ? send_data(message) : message
      end


      class SocketResponse
        attr_accessor :headers, :body, :data
        def initialize(data)
          @data = ""
          @data << data
          headers, @body = data.split("\n\n")  # Initialize data as a string for '<<' method
          @body ||= ""
          @headers = YAML.load(headers)
          FSR::Log.debug("New #{self.class.name} created: #{self}")
        end

        def <<(data)
          extra_headers, more_body = data.split("\n\n")
          @headers.merge(extra_headers)
          @body << more_body unless more_body.nil?
          self
        end
      end

      class Session < SocketResponse
        def initiated?
          @headers.keys.include?("Control")
        end
      end

      class CommandReply < SocketResponse
      end
    end

  end
end
