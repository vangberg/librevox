require 'spec/helper'
require "fsr/cmd"
FSR::Cmd.load_command("calls")

describe "Testing FSR::Cmd::Calls" do
  ## Calls ##
  # Interface to calls
  it "FSR::Cmd::Calls should send show calls" do
    sofia = FSR::Cmd::Calls.new
    sofia.raw.should == "show calls"
  end

end
