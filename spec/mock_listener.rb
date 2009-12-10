require 'fsr/listener'

class FSR::Listener::Base
  attr_accessor :outgoing_data

  def initialize(*args)
    @outgoing_data = []
    super *args
  end

  def send_data(data)
    @outgoing_data << data
  end

  def read_data
    @outgoing_data.pop
  end
end
