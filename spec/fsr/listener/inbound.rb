require 'spec/helper'
require "fsr/listener/inbound"

# Bare class to use for testing
class MyListener
  include FSR::Listener::Inbound
end

# helper to instantiate a new MyListener
def my_listener
  MyListener.new
end

describe "Testing FSR::Listener::Inbound" do

  it "defines #post_init" do
    FSR::Listener::Inbound.method_defined?(:post_init).should == true
  end

  it "Errors when calling #post_init, send_data is not yet defined" do
    begin
      my_listener.post_init
    rescue => e
      e.kind_of?(NoMethodError).should == true
    end
  end

  it "Receives data with #receive_data and returns a FSR::Listener::Inbound::Event object" do
    listener = my_listener
    event = listener.receive_data("Fake_Header: foo\nControl: full\n\n")
    event.kind_of?(FSR::Listener::Inbound::Event).should == true
  end

  it "should call the on_event hook after an event  is received" do
    class IesTest
      attr_accessor :called
      include FSR::Listener::Inbound
      def initialize
        @called = false
      end
      def on_event(event)
        @called = true
      end
    end
    listener = IesTest.new
    event = listener.receive_data("Fake_Header: foo\nControl: full\n")
    listener.called.should.be.true?
  end

end
