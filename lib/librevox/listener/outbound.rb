require 'librevox/listener/base'
require 'librevox/applications'

module Librevox
  module Listener
    class Outbound < Base
      include Librevox::Applications

      def application app, args=nil, params={}, &block
        msg = "sendmsg\n"
        msg << "call-command: execute\n"
        msg << "execute-app-name: #{app}\n"
        msg << "execute-app-arg: #{args}\n" if args && !args.empty?

        send_data "#{msg}\n"

        @application_queue.push(proc {
          update_session do
            arg = params[:variable] ? variable(params[:variable]) : nil
            block.call(arg) if block
          end
        })
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
        @application_queue << proc {}
        send_data "linger\n\n"
        @application_queue << proc {session_initiated}
      end

      def handle_response
        if session.nil?
          @session = response.headers
        elsif response.event? && response.event == "CHANNEL_DATA"
          @session = response.content
        elsif response.command_reply? && !response.event?
          @application_queue.shift.call(response) if @application_queue.any?
        end

        super
      end

      def variable name
        session[:"variable_#{name}"]
      end

      def update_session &block
        api.command "uuid_dump", session[:unique_id], &block
      end
    end
  end
end
