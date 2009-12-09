require 'fsr/listener/inbound'
require 'fsr/listener/outbound'

class String
  alias :each :each_line
end

FSL = FSR::Listener
