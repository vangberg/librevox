require 'spec/helper'
require "fsr/cmd"
FSR::Cmd.load_command("originate")

describe "Testing FSR::Cmd::Originate" do
  # Originate to an extension
  it "Originates calls to extensions" do
    originate = FSR::Cmd::Originate.new(nil, :target => "user/bougyman", :endpoint => "4000")
    originate.raw.should == "originate {ignore_early_media=true,originate_timeout=30,origination_caller_id_name=FSR,origination_caller_id_number=8675309}user/bougyman 4000"
  end

end
