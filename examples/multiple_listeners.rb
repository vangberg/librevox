require 'librevox'

class SomeInbound < Librevox::Listener::Inbound
  def on_event e
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
