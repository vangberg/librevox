require "fsr/app"
module FSR
  module App
    class Api < Application
      attr_reader :command

      def initialize(command)
        @command = command #  Command to send via API
      end

      def arguments
        [@command]
      end

      def sendmsg
        "no sendmsg"
      end

      SENDMSG_METHOD = %q|
        def api(*args, &block)
          me = super(*args)
          @api_request = true
          send_data("api #{me.command}\n\n")
          @queue.unshift block if block_given?
        end
      |
    end

    register(:api, Api)
  end
end
