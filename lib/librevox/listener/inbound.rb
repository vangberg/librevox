require 'librevox/listener/base'

module Librevox
  module Listener
    class Inbound < Base
      class << self
        attr_reader :subscribe_events
        attr_reader :subscribe_filters

        def events(events)
          @subscribe_events = events
        end

        def filters(filters)
          @subscribe_filters = filters
        end
      end

      def initialize args={}
        super

        @auth = args[:auth] || "ClueCon"
        @host, @port = args.values_at(:host, :port)

        EventMachine.add_shutdown_hook {@shutdown = true}
      end

      def connection_completed
        Librevox.logger.info "Connected."
        super

        send_data "auth #{@auth}\n\n"

        events = self.class.subscribe_events || ['ALL']
        send_data "event plain #{events.join(' ')}\n\n"

        filters = self.class.subscribe_filters || {}
        filters.each do |header, values|
          [*values].each do |value|
            send_data "filter #{header} #{value}\n\n"
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
