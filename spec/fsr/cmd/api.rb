require 'spec/helper'
require 'fsr/cmd'

describe FSR::Cmd::API do
  should "execute api command" do
    cmd = FSR::Cmd::API.new("foo")
    cmd.raw.should == "api foo"
  end

  should "execute api command with args" do
    cmd = FSR::Cmd::API.new("foo", "bar", "baz")
    cmd.raw.should == "api foo bar baz"
  end
end
