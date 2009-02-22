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
     my_listener.receive_data("Fake_Header: foo\nControl: full\n\n").should == "Fake_Header: foo\nControl: full\n\n"
  end

end
