require 'spec/helper'
require 'fsr/cmd'

describe FSR::Cmd::UuidBridge do
  should "bridge call legs" do
    cmd = FSR::Cmd::UuidBridge.new("leg1", "leg2")
    cmd.raw.should == "api uuid_bridge leg1 leg2"
  end
end
