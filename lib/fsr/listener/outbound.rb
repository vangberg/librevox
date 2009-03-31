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
      # Either as a Session, a continuation of a Session, or as a Session's last CommandReply
      def receive_data(data)
        FSR::Log.debug("received #{data}")
        if @session.nil? # if @session is nil, create a new Session object
          @session = Session.new(data)
          session_initiated(@session) if @session.initiated?
        else
          # If it's not nil, we add the data to this session, Session knows whether
          # or not to create a CommandReply, complete a CommandReply, or simply add to
          # its own @data array and @headers/@body structures
          if @session.initiated?
            @session << data
            reply_received(@session.replies.last) if @session.replies.last.complete?
          else
            @session << data
            session_initiated(@session) if @session.initiated?
          end
        end
        @session
      end

      def session_initiated(session)
        session
      end

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
        def initialize(data = "")
          @data = [data]
          @headers = {}
          if data.match(/\n$/)
            headers, @body = data.split("\n\n")
            headers.each_line do |line|
              key, value = line.split(":")
              @headers[key] = value.to_s.strip
            end
          end
          @body ||= ""
          FSR::Log.debug("New #{self.class.name} created: #{self}")
        end

        def <<(data)
          if data.match(/\n$/)
            @data.last.match(/\n$/) ? @data << data : @data.last << data
            extra_headers, more_body = @data.last.split("\n\n")
            extra_headers.each_line do |line|
              key, value = line.split(":")
              @headers[key] = value.to_s.strip
            end
            @body << more_body unless more_body.nil?
          else
            @data.last.match(/\n$/) ? @data << data : @data.last << data
          end
          self
        end
      end

      class Session < SocketResponse
        attr_accessor :replies
        def initialize(data = "")
          super
          @replies = []
        end

        def <<(data)
          if initiated?
            if @replies.empty? or @replies.last.complete?
              @replies << CommandReply.new(data)
            else
              @replies.last << data
            end
          else
            super
          end
        end

        def initiated?
          @headers.keys.include?(:control)
        end
        
      end

      class CommandReply < SocketResponse
        # Set this to true for now, fill it in when we know what completed a reply
        def complete?
          true
        end
      end
    end

  end
end
