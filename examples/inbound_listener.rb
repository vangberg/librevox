require 'librevox'
 
class MyInbound < Librevox::Listener::Inbound
  # `on_event` is called every time an event is received.
  def on_event e
    # Be sure to check out the content of `e`. It has all the good stuff.
  end
 
  # You can add a hook for a certain event:
  event :channel_hangup do
    # It is instance_eval'ed, so you can use your instance methods etc:
    do_something
  end
 
  def do_something
    # ...
  end
end

Librevox.options[:log_file] = "foo.log"
Librevox.start MyInbound
