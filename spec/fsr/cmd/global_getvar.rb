require 'spec/helper'
require 'fsr/cmd'

describe FSR::Cmd::GlobalGetvar do
  before do
    @cmd = FSR::Cmd::GlobalGetvar.new("foo")
  end

  should "call global_getvar" do
    @cmd.raw.should == "api global_getvar foo"
  end

  should "return value" do
    @cmd.response = FSR::Response.new("Content-Type: api/response\nContent-Length: 5\n", "value")
    @cmd.response.should == "value"
  end
end
