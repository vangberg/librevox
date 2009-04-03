require 'spec/helper'
require "fsr/listener/inbound"

# Bare class to use for testing
class MyListener < FSR::Listener::Inbound
end

# helper to instantiate a new MyListener
def my_listener
  MyListener.new
end

describe "Testing FSR::Listener::Inbound" do

  it "defines #post_init" do
    FSR::Listener::Inbound.method_defined?(:post_init).should == true
  end

end
