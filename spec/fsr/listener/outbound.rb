require 'spec/helper'
require "fsr/listener/outbound"

# Bare class to use for testing
class MyListener
  include FSR::Listener::Outbound
end

# helper to instantiate a new MyListener
def my_listener
  MyListener.new
end

describe "Testing FSR::Listener::Outbound" do

  it "defines #post_init" do
    FSR::Listener::Outbound.method_defined?(:post_init).should == true
  end

  it "Errors when calling #post_init, send_data is not yet defined" do
    begin
      my_listener.post_init
    rescue => e
      e.kind_of?(NoMethodError).should == true
    end
  end

  it "Receives data with #receive_data and creates a valid session" do
    session = my_listener.receive_data("Fake_Header: foo\n\nbody")
    session.kind_of?(FSR::Listener::Outbound::Session).should == true
    session.headers.keys.include?("Fake_Header").should == true
    session.headers["Fake_Header"].should == "foo"
    session.body.should == "body"
  end

  it "Receives data with #receive_data as a CommandReply" do
    listener = my_listener
    listener.receive_data("Fake_Header: foo\n\nbody").kind_of?(FSR::Listener::Outbound::Session).should == true
    (reply = listener.receive_data("Fake_Header: foo\n\nbody")).kind_of?(FSR::Listener::Outbound::CommandReply).should == true
    reply.headers["Fake_Header"].should == "foo"
    reply.body.should == "body"
  end

end
