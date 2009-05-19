require 'spec/helper'
require "fsr/listener/inbound"

# Bare class to use for testing
class MyListener < FSR::Listener::Inbound
  attr_reader :history

  def initialize(*args)
    @history = []
    super
  end

  def send_data(message)
    history << message
  end
end

# helper to instantiate a new MyListener
def my_listener
  listener = MyListener.new(signature = 'foo')
  listener
end

describe "Testing FSR::Listener::Inbound" do
  it "defines #post_init" do
    FSR::Listener::Inbound.method_defined?(:post_init).should == true
  end

  it "adds and deletes hooks" do
    FSL::Inbound.add_event_hook(:CHANNEL_CREATE) {|event| puts event.inspect }
    FSL::Inbound::HOOKS.size.should == 1
    FSL::Inbound.del_event_hook(:CHANNEL_CREATE)
    FSL::Inbound::HOOKS.size.should == 0
  end

  it 'invokes hooks' do
    history = []

    FSL::Inbound.add_event_hook(:CHANNEL_CREATE){|event| history << event }

    l = my_listener
    l.history.should == [ "auth ClueCon\r\n\r\n", "event plain ALL\r\n\r\n" ]
    l.receive_request(["testing: true"], ["event-name: CHANNEL_CREATE"])

    history.size.should == 1
    event = history.first
    event.event_name.should == 'CHANNEL_CREATE'
  end

  it "doesn't invoke deleted hooks" do
    history = []

    FSL::Inbound.del_event_hook(:CHANNEL_CREATE)

    l = my_listener
    l.history.should == [ "auth ClueCon\r\n\r\n", "event plain ALL\r\n\r\n" ]
    l.receive_request(["testing: true"], ["event-name: CHANNEL_CREATE"])

    history.size.should == 0
  end

  it "invokes on_event even if a hook raises" do
    FSL::Inbound.add_event_hook(:CHANNEL_CREATE){|event| raise "fail" }

    l = my_listener

    # define on_event on the instance and give us a way to get the last event
    # that reached the #on_event method.
    def l.on_event(event) @event = event; end
    def l.event; @event; end

    l.history.should == [ "auth ClueCon\r\n\r\n", "event plain ALL\r\n\r\n" ]
    lambda{
      l.receive_request(["testing: true"], ["event-name: CHANNEL_CREATE"])
    }.should.raise

    l.event.event_name.should == 'CHANNEL_CREATE'
    l.event.headers[:testing].should == 'true'
  end
end
