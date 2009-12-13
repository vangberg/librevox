require 'librevox/listener/base'

module Librevox
  module Listener
    class Inbound < Base
      def initialize(args={})
        super

        @auth = args[:auth] || "ClueCon"
      end

      def post_init
        super
        send_data "auth #{@auth}\n\n"
        send_data "event plain ALL\n\n"
      end
    end
  end
end
