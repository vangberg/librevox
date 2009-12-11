require 'spec/helper'
require 'fsr/cmd'

describe FSR::Cmd::GlobalSetvar do
  should "set variable" do
    cmd = FSR::Cmd::GlobalSetvar.new("foo", "bar")
    cmd.raw.should == "api global_setvar foo=bar"
  end
end
