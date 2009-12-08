require 'fsr/listener/base'
require 'fiber'

module FSR
  module Listener
    class Outbound < Base
      def self.register_app(klass)
        define_method klass.new.app_name do |*args|
          app = klass.new(*args)
          send_data app.sendmsg

          if app.read_channel_var
            @read_channel_var = app.read_channel_var
            update_session
          else
            @read_channel_var = nil
          end

          Fiber.yield
        end
      end

      attr_accessor :session

      def post_init
        @session = nil

        send_data "connect\n\n"
        send_data "myevents\n\n"
        send_data "linger\n\n"
      end

      def receive_request(*args)
        super(*args)

        if session.nil?
          @session = response
          @app = Fiber.new {session_initiated}
          @app.resume
        elsif response.event? && response.event == "CHANNEL_DATA"
          @session = response
          resume_with_channel_var
        else
          @app.resume if @app.alive?
        end
      end

      def resume_with_channel_var
        if @read_channel_var
          value = @session.content[@read_channel_var.to_sym]
          @app.resume value
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

