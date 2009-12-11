require 'spec/helper'
require 'fsr/cmd'

describe FSR::Cmd::ReloadXML do
  should "reload xml" do
    cmd = FSR::Cmd::ReloadXML.new
    cmd.raw.should == "api reloadxml"
  end
end
