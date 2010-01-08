require 'fsr'
require 'fsr/listener/outbound'

class SomeInbound < Librevox::Listener::Inbound
  def on_event
    # ...
  end
end

class SomeOutbound < Librevox::Listener::Outbound
  def session_initiated
    # ...
  end
end

Librevox.start do
  run SomeInbound
  run SomeOutbound
end
