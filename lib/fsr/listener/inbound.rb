require 'fsr/listener/base'

module FSR
  module Listener
    class Inbound < Base
      def initialize(args={})
        super

        @auth = args[:auth] || "ClueCon"
      end

      def post_init
        send_data "auth #{@auth}\n\n"
        send_data "event plain ALL\n\n"
      end
    end
  end
end
