require 'fsr/listener'

module FSR
  module App
    APPLICATIONS = []

    def self.register(app)
      APPLICATIONS << app
      FSR::Listener::Outbound.register_app(app)
    end

    class Application
      def self.app_name
        name.split("::").last.downcase
      end

      def app_name
        self.class.app_name
      end

      def to_s
        sendmsg
      end

      def arguments
        []
      end

      def event_lock
        false
      end

      # I don't like this name. But it'll do for now. ~harry
      def read_channel_var
        nil
      end

      def raw
        "%s(%s)" % [app_name, arguments.join(" ")]
      end

      def sendmsg
        msg = "call-command: execute\nexecute-app-name: %s\n" % app_name
        msg += "execute-app-arg: %s\n" % arguments.join(" ") if arguments.any?
        msg += "event-lock: true\n" if event_lock
        msg += "\n"
      end
    end
  end
end

Dir[File.join(File.dirname(__FILE__), "app", "*.rb")].each do |app|
  require app
end

FSA = FSR::App
