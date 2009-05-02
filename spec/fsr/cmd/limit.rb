require 'spec/helper'
require "fsr/cmd"
FSR::Cmd.load_command("limit")

describe "Testing FSR::Cmd::Limit" do
  ## Calls ##
  # Interface to calls
  it "FSR::Cmd::Limit should send proper limit command only passing an id" do
    limit = FSR::Cmd::Limit.new(nil, "fsr_caller")
    limit.raw.should == "limit $${domain} fsr_caller 5"
  end

  it "FSR::Cmd::Limit should send proper limit command passing id and realm" do
    limit = FSR::Cmd::Limit.new(nil, "fsr_caller", "foodomain")
    limit.raw.should == "limit foodomain fsr_caller 5"
  end

  it "FSR::Cmd::Limit should send proper limit command passing id, realm, and limit" do
    limit = FSR::Cmd::Limit.new(nil, "fsr_caller", "foodomain", 10)
    limit.raw.should == "limit foodomain fsr_caller 10"
  end

end
