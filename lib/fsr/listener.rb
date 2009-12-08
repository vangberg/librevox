require 'fsr/listener/outbound'
require 'fsr/listener/inbound'

class String
  alias :each :each_line
end

FSL = FSR::Listener
