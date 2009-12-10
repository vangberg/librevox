require 'fsr'
require 'fsr/listener/inbound'
 
class MyInbound < FSR::Listener::Inbound
  # `on_event` is called every time an event is received.
  def on_event
    # Be sure to check out the content of `event`. It has all the good stuff.
    FSR::Log.info "Got event: #{event.content[:event_name]}"
  end
 
  # You can add a hook for a certain event:
  add_event_hook :CHANNEL_HANGUP do
    FSR::Log.info "Channel hangup!"
 
    # It is instance_eval'ed, so you can use your instance methods etc:
    do_something
  end
 
  def do_something
    # ...
  end
end

FSR.start MyInbound
