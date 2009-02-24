require 'fsr/listener'
require 'fsr/listener/inbound/event.rb'
module FSR
  module Listener
    module Inbound 
      include FSR::Listener

      def post_init
        say('auth ClueCon')
        say('event plain ALL')
      end
   
      def receive_data(data)
        event = Event.from(data)
        on_event(event)
      end

      def say(line)
        send_data("#{line}\n\n")
      end

      def on_event(event)
        event
      end

    end
  end
end
