require 'librevoz/listener/base'
require 'librevoz/applications'

module Librevoz
  module Listener
    class Outbound < Base
      include Librevoz::Applications

      def execute_app(app, args=[], read_var=nil, &block)
        msg = "sendmsg\n"
        msg << "call-command: execute\n"
        msg << "execute-app-name: #{app}\n"
        msg << "execute-app-arg: %s\n" % args.join(" ") if args.any?
        send_data "#{msg}\n"

        @read_channel_var = read_var

        if @read_channel_var
          @command_queue << lambda {update_session}
        end

        @command_queue << (block_given? ? block : lambda {})
      end

      # This should probably be in Application#sendmsg instead.
      def sendmsg(msg)
        send_data "sendmsg\n%s" % msg
      end

      attr_accessor :session

      def post_init
        super
        @session = nil
        @command_queue = []

        send_data "connect\n\n"
        send_data "myevents\n\n"
        @command_queue << lambda {}
        send_data "linger\n\n"
        @command_queue << lambda {}
      end

      def receive_request(*args)
        super(*args)
        
        if session.nil?
          @session = response
          session_initiated
        elsif response.event? && response.event == "CHANNEL_DATA"
          @session = response
          resume_with_channel_var
        elsif response.command_reply? && !response.event?
          @command_queue.shift.call if @command_queue.any?
        end
      end

      def resume_with_channel_var
        if @read_channel_var
          variable = "variable_#{@read_channel_var}".to_sym
          value = @session.content[variable]
          @command_queue.shift.call(value) if @command_queue.any?
        end
      end

      def update_session
        send_data("api uuid_dump #{session.headers[:unique_id]}\n\n")
      end

      def session_initiated
      end
    end
  end
end
