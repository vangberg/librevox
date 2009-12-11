require 'spec/helper'
require 'fsr/cmd'

describe FSR::Cmd::Reload do
  should "load module" do
    cmd = FSR::Cmd::Load.new("some_mod")
    cmd.raw.should == "api load some_mod"
  end
end
