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
        @session_collected = nil # set to false until we have collected the initial variable dump
        @session = nil # holds the session object
        @session_completed = true # Insure statements are only executed once per session, not per receive_data
        send_data("connect\n\n")
        FSR::Log.debug "Accepting connections."
      end

      def receive_data(data)
        FSR::Log.debug("received #{data}")
        if @session_collected.nil? # If session_collected is true, no need to call our on_call hook.  We only want to execute once per call right?
          FSR::Log.debug("New Session, calling collect_session_dump on #{@session}")
          collect_session_dump(data)
        else
          FSR::Log.debug "@session is #{@session}"
          FSR::Log.debug("Command reply received, calling reply_received on #{data}")
          #receive_response(data) # TODO: Need to write collect_response
        end
      end

      def collect_session_dump(dump)
        @session = Session.new if @session.nil?
        dump.each do |line|
          if line.match(/Control:/) # Last line of a new session dump ends with "Control:"
            @session_collected = true
            @session.collect_response(dump) # Collect last line
            @session.make_headers # Turn raw data in a hash 
            call_dispatcher(@session) # It is now safe to call the dispatcher, which will in turn call our hook "on_call"
          else
            @session.collect_response(dump)
          end
        end
      end

      def receive_response(dump)
        @response = SocketResponse.new
        @response.collect_response(dump)
      end

      def call_dispatcher(session)
        #before_hook
        on_call(session)
        #after_hook
      end

      # This is the method a user would define to use the library
      def on_call(session)
        session
      end

      def sendmsg(message)
        if message.kind_of?(FSR::App::Application)
          text = message.sendmsg
        elsif message.kind_of?(String)
          text = message
        else
          raise "sendmsg only accepts String or FSR::App::Application instances"
        end
        FSR::Log.debug "sending #{text}"
        message = "sendmsg\n%s" % text
        self.class.method_defined?(:send_data) ? send_data(message) : message
      end


      class SocketResponse
        attr_accessor :headers, :body, :data
        def initialize
          @data = ""  # Initialize data as a string for '<<' method
        end

        def collect_response(data)
          @data << data
        end

        def make_headers
          @headers = YAML.load(@data)
        end

      end

      class Session < SocketResponse
      end

      class CommandReply < SocketResponse
      end
    end

  end
end
