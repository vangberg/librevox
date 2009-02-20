module FSR
  module Listener 

    def receive_data(data)
      FSR::Log.debug "Received #{data}"
    end

  end
end
FSL = FSR::Listener
