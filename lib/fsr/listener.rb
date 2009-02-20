require 'eventmachine'
module FSR
  module Listener 
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
