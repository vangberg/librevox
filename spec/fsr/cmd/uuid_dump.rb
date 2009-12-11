require 'spec/helper'
require "fsr/cmd"

describe "Testing FSR::Cmd::UuidDump" do
  ## Calls ##
  # Interface to calls
  it "FSR::Cmd::UuidDump should send uuid_dump <uid>" do
    cmd = FSR::Cmd::UuidDump.new(nil, "abcd-1234-efgh-5678")
    cmd.raw.should == "uuid_dump abcd-1234-efgh-5678"
  end

end
