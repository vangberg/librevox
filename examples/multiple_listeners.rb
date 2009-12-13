require 'fsr'
require 'fsr/listener/outbound'

class SomeInbound < Librevox::Listener::Inbound
  def on_event
    # ...
  end
end

class SomeOutbound < Librevox::Listener::Outbound
  session do
    # ...
  end
end

Librevox.start do
  run SomeInbound
  run SomeOutbound
end
