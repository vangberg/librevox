require 'librevox/listener/base'
require 'librevox/applications'

module Librevox
  module Listener
    class Outbound < Base
      include Librevox::Applications

      def execute_app(app, args="", params={}, &block)
        msg = "sendmsg\n"
        msg << "call-command: execute\n"
        msg << "execute-app-name: #{app}\n"
        msg << "execute-app-arg: #{args}\n" unless args.empty?

        send_data "#{msg}\n"

        @read_channel_var = params[:read_var]

        if @read_channel_var
          @application_queue << lambda {update_session}
        end

        @application_queue << (block || lambda {})
      end

      # This should probably be in Application#sendmsg instead.
      def sendmsg(msg)
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
        @application_queue << lambda {}
        send_data "linger\n\n"
        @application_queue << lambda {}
      end

      def receive_request(*args)
        super(*args)
        
        if session.nil?
          @session = response.headers
          session_initiated
        elsif response.event? && response.event == "CHANNEL_DATA"
          @session = response.content
          resume_with_channel_var
        elsif response.command_reply? && !response.event?
          @application_queue.shift.call if @application_queue.any?
        end
      end

      def resume_with_channel_var
        if @read_channel_var
          variable = "variable_#{@read_channel_var}".to_sym
          value = @session[variable]
          @application_queue.shift.call(value) if @application_queue.any?
        end
      end

      def update_session &block
        send_data("api uuid_dump #{session[:unique_id]}\n\n")
        @command_queue << (block || lambda {})
      end
    end
  end
end
