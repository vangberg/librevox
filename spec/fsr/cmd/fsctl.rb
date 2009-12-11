require 'spec/helper'
require 'fsr/cmd'

describe FSR::Cmd::FSCTL do
  should "send command" do
    cmd = FSR::Cmd::FSCTL.new
    cmd.raw.should == "api fsctl"
  end

  should "send arguments" do
    cmd = FSR::Cmd::FSCTL.new(:hupall, :normal_clearing)
    cmd.raw.should == "api fsctl hupall normal_clearing"
  end
end
