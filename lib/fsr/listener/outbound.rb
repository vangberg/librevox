require "yaml"
module FSR
  class Listener
    class Outbound < FSR::Listener

      def post_init
        @session_data = {}
        send_data("connect\n\n")
        FSR::Log.debug "Accepting connections."
      end

      def receive_data(data)
        FSR::Log.debug("received #{data}")
        headers, body = data.split(/\n\n/)
        hash = YAML.load(headers)
        FSR::Log.debug("Data hash is #{hash.inspect}")
        FSR::Log.debug("Body is #{body || 'empty'}")
        session_initiated(hash.merge(:body => body))
      end

      def session_initiated(data)
      end

      def sendmsg(message)
        if message.kind_of?(FSR::App::Application)
          text = message.sendmsg
        elsif message.kind_of?(String)
          text = message
        else
          raise "sendmsg only accepts String or FSR::App::Application instances"
        end
        FSR::Log.debug "sending #{text}"
        send_data("sendmsg\n%s" % text)
      end

      def transfer(target)
        sendmsg(FSR::App::Bridge.new(target))
      end

    end
  end
end
