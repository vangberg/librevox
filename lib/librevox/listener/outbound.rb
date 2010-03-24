require 'librevox/listener/base'
require 'librevox/applications'

module Librevox
  module Listener
    class Outbound < Base
      include Librevox::Applications

      def application app, args=nil, params={}
        msg = "sendmsg\n"
        msg << "call-command: execute\n"
        msg << "execute-app-name: #{app}\n"
        msg << "execute-app-arg: #{args}\n" if args && !args.empty?

        send_data "#{msg}\n"

        @application_queue << Fiber.current

        Fiber.yield
        update_session

        params[:variable] ? variable(params[:variable]) : nil
      end

      # This should probably be in Application#sendmsg instead.
      def sendmsg msg 
        send_data "sendmsg\n%s" % msg
      end

      attr_accessor :session
      
      # Called when a new session is initiated.
      def session_initiated
      end

      def post_init
        super
        @session = nil
        @application_queue = []

        send_data "connect\n\n"
        send_data "myevents\n\n"
        @application_queue << Fiber.new {}
        send_data "linger\n\n"
        @application_queue << Fiber.new {session_initiated}
      end

      def handle_response
        if session.nil?
          @session = response.headers
        elsif response.event? && response.event == "CHANNEL_DATA"
          @session = response.content
        elsif response.command_reply? && !response.event?
          @application_queue.shift.resume if @application_queue.any?
        end

        super
      end

      def variable name
        session[:"variable_#{name}"]
      end

      def update_session
        api.command "uuid_dump", session[:unique_id]
      end
    end
  end
end
