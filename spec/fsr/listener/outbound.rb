require 'spec/helper'
require "fsr/listener/outbound"

# Bare class to use for testing
class MyListener < FSR::Listener::Outbound
  attr_reader :history

  def initialize(*args)
    @history = []
    super
  end

  def send_data(message)
    history << message
  end

  def session_initiated
    # stop whining
  end
end

# helper to instantiate a new MyListener
def my_listener
  listener = MyListener.new(signature = 'foo')
  listener.session_initiated
  listener
end

describe "Testing FSR::Listener::Outbound" do
  it "defines #post_init" do
    FSR::Listener::Outbound.method_defined?(:post_init).should == true
  end

  it 'uses send_data to send messages' do
    listener = my_listener
    listener.sendmsg('foo')
    listener.history.should == [ "connect\n\n", "sendmsg\nfoo\n" ]
  end

  it 'receives requests and puts them into a plain HeaderAndContentResponse' do
    l = my_listener
    l.receive_request "foo: bar\n\nx: y", "nothing special"
    l.history.should == [ "connect\n\n" ]
    l.session.headers.should == {:foo => 'bar', :x => 'y'}
    l.session.event_name.should == ''
  end

  it 'receives requests and puts them into a plain ParsedContent' do
    l = my_listener
    l.receive_request "foo: bar\n\nx: y", "nothing: special\nevent_name:foobar"
    l.history.should == [ "connect\n\n" ]
    l.session.headers.should == {:foo => 'bar', :x => 'y'}
    l.session.event_name.should == 'foobar'
  end
end
