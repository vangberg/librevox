require 'fsr'
require 'fsr/listener/outbound'

class SomeInbound < FSR::Listener::Inbound
  def on_event
    # ...
  end
end

class SomeOutbound < FSR::Listener::Outbound
  def session_initiated
    # ...
  end
end

FSR.start do
  run SomeInbound
  run SomeOutbound
end
