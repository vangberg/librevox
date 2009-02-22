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
    listener = my_listener
    session = listener.receive_data("Fake_Header: foo\nControl: full\n\n")
    session.kind_of?(FSR::Listener::Outbound::Session).should == true
    session.headers["Control"].should == "full"
    session.headers["Fake_Header"].should == "foo"
    session.initiated?.should == true
    session.body.should == ""
  end

  it "Receives data with multiple #receive_data calls and creates a valid session and replies" do
    listener = my_listener
    # Receive and incomplete session as data
    session = listener.receive_data("Fake_Header: foo")
    session.class.should.be.identical_to FSR::Listener::Outbound::Session
    session.initiated?.should.be.false?
    session.headers["Fake_Header"].should == "foo"
    session.data.size.should.be.identical_to 1
    # Receive more data, still incomplete session
    session2 = listener.receive_data("Another_Fake_Header: bar")
    session2.should.be.identical_to session
    session2.initiated?.should.be.false?
    session2.headers["Another_Fake_Header"].should == "bar"
    session2.body.should == ""
    session2.data.size.should.be.identical_to 2
    # Receive more data, complete the session
    session3 = listener.receive_data("Yet_Another_Fake_Header: baz\nControl: full")
    session3.should.be.identical_to session2
    session3.headers["Yet_Another_Fake_Header"].should == "baz"
    session3.initiated?.should.be.true?
    session3.headers["Control"].should == "full"
    session3.body.should == ""
    session3.data.size.should.be.identical_to 3
    # Now receive more data, should add a command
    session4 = listener.receive_data("Content-Type: command/reply\nContent-Disposition: +OK\n\nCommand Completed")
    session4.should.be.identical_to session3
    session4.replies.size.should.be.identical_to 1
    reply = session4.replies.last
    reply.class.should.be.identical_to FSR::Listener::Outbound::CommandReply
    reply.complete?.should.be.true?
    reply.headers["Content-Disposition"].should == "+OK"
    reply.body.should == "Command Completed"
  end

end
