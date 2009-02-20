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
        @session = nil
        send_data("connect\n\n")
        FSR::Log.debug "Accepting connections."
      end

      def receive_data(data)
        FSR::Log.debug("received #{data}")
        FSR::Log.debug("Data hash is #{hash.inspect}")
        FSR::Log.debug("Body is #{body || 'empty'}")
        if @session.nil?
          @session = Session.new(data)
          FSR::Log.debug("New Session, calling session_initiated on #{@session}")
          session_initiated(@session)
        else
          command_reply = CommandReply.new(data)
          FSR::Log.debug("Command reply received, calling reply_received on #{command_reply}")
          reply_received(command_reply)
        end
      end

      def session_initiated(session)
      end

      def reply_received(command_reply)
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
        def initialize(data)
          headers, @body = data.split(/\n\n/)
          @headers = YAML.load(headers)
        end
      end

      class Session < SocketResponse
      end

      class CommandReply < SocketResponse
      end
    end

  end
end
