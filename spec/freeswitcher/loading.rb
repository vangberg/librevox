require 'spec/helper'

# Must include spec/helper to run this test

describe "Testing FreeSwitcher module methods" do
  it "Loads all applications" do
    apps_loaded = FreeSwitcher.load_all_applications
    apps_loaded.kind_of?(Array).should == true
    apps_loaded.should == [:conference, :bridge]
  end

  it "Loads all commands" do
    cmds_loaded = FreeSwitcher.load_all_commands
    cmds_loaded.kind_of?(Array).should == true
    cmds_loaded.should == [:originate]
  end
end
