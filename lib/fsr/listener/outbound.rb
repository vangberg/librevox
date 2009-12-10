require 'fsr/listener/base'
require 'fsr/app'

module FSR
  module Listener
    class Outbound < Base
      def self.register_app(klass)
        class_eval <<-EOF
          def #{klass.app_name}(*args, &block)
            run_app(#{klass}, *args, &block)
          end
        EOF
      end

      FSR::App::APPLICATIONS.each do |app|
        register_app(app)
      end

      def run_app(klass, *args, &block)
        app = klass.new(*args)
        sendmsg app.sendmsg

        if app.read_channel_var
          @read_channel_var = app.read_channel_var
          @command_queue << lambda {update_session}
        else
          @read_channel_var = nil
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
          @command_queue.shift.call(value)
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

