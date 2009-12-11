require 'fsr/command_socket'

module FSR
  module Cmd
    COMMANDS = []

    def self.register(cmd)
      COMMANDS << cmd
      FSR::CommandSocket.register_cmd(cmd)
    end

    class Command
      attr_reader :response
      attr_writer :background

      def self.cmd_name
        name.split("::").last.downcase
      end

      def cmd_name
        self.class.cmd_name
      end

      def arguments
        []
      end

      def background
        @background ||= false
      end

      def response=(r)
        @response = r
      end

      # I don't like the look of this method. ~harry
      def raw
        msg = background ? "bgapi" : "api"
        msg += " %s" % cmd_name
        msg += " %s" % arguments.join(" ") if arguments.any?
        msg
      end
    end
  end
end

Dir[File.join(File.dirname(__FILE__), "cmd", "*.rb")].each do |cmd|
  require cmd
end

FSC = FSR::Cmd
