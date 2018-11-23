require 'librevox/listener/base'

module Librevox
  module Listener
    class Inbound < Base
      def initialize args={}
        super

        @auth = args[:auth] || "ClueCon"
        @host, @port = args.values_at(:host, :port)

        EventMachine.add_shutdown_hook {@shutdown = true}
      end

      @@filters = {}
      def self.filters(filters)
        @@filters = filters
      end

      @@events = ['ALL']
      def self.events(events)
        @@events = [*events]
      end

      def connection_completed
        Librevox.logger.info "Connected."
        super

        send_data "auth #{@auth}\n\n"

        send_data "event plain #{@@events.join(' ')}\n\n"

        @@filters.each do |header, filters|
          [*filters].each do |filter|
            send_data "filter #{header} #{filter}\n\n"
          end
        end
      end

      def unbind
        if !@shutdown
          Librevox.logger.error "Lost connection. Reconnecting in 1 second."
          EM.add_timer(1) {reconnect(@host, @port.to_i)}
        end
      end
    end
  end
end
