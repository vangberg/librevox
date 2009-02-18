require 'eventmachine'
module FSR
  class Listener < EventMachine::Connection
    def dispatch(event)
      name = event.listener_name
      return unless respond_to?(name)
      send(name)
    end

    def receive_data(data)
      #dispatch(data)
    end

    def call
    end

    def hangup
    end
  end
end
