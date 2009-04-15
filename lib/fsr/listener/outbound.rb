require 'rubygems'
require 'eventmachine'
require 'fsr/listener'
require 'fsr/listener/header_and_content_response'

module FSR
  load_all_applications
  module Listener
    class Outbound < EventMachine::Protocols::HeaderAndContentProtocol

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

      def receive_request(header, content)
        hash_header = headers_2_hash(header)
        hash_content = headers_2_hash(content)
        session = HeaderAndContentResponse.new({:headers => hash_header, :content => hash_content})
        if @session.nil?
          @session = session
          session_initiated(session) 
        else
          if session.headers[:event_calling_function].to_s.match(/uuid_dump/i)
            @session = session
          else
            receive_reply(session)
          end
        end
      end

      # Received data dispatches the data received by the EM socket,
      # Either as a Session, a continuation of a Session, or as a Session's last CommandReply
      
      def session_initiated(session)
        session
      end

      def receive_reply(session)
        session
      end

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

      # Update_session

      def update_session
        send_data("api uuid_dump #{@session.headers[:unique_id]}")
      end

    end

  end
end
