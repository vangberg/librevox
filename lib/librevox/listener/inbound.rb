require 'librevox/listener/base'

module Librevox
  module Listener
    class Inbound < Base
      class << self

        def filters
          @filters ||= {}
        end

        def filter(header, values)
          @filters ||= {}
          @filters[header] = [*values]
        end

        def events
          @events || ['ALL']
        end

        def event(event)
          @events ||= []
          @events << event
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

        send_data "event plain #{self.class.events.join(' ')}\n\n"

        self.class.filters.each do |header, values|
          values.each do |value|
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
