module FSR
  class Listener
    class Outbound < FSR::Listener

      def post_init
        send_data("connect\n\n")
        FSR::Log.debug "Accepting connections."
      end

      def receive_data(data)
        FSR::Log.debug "Receiving data."
        puts data 
      end

    end
  end
end
