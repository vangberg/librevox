module FSR
  class Listener
    def dispatch(event)
      name = event.listener_name
      return unless respond_to?(name)
      send(name)
    end

    def call
    end

    def hangup
    end
  end
end
