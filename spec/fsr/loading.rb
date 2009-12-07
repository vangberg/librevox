require 'spec/helper'


describe "Testing FSR module loading methods" do
  # When you add commands  you must modify the expected cmds_loaded behavior
  it "Loads all commands" do
    all_commands = [:uuid_dump, :originate, :sofia, :fsctl, :sofia_contact, :status, :calls] # If you add a command add it to this set
    cmds_loaded = FSR.load_all_commands
    cmds_loaded.kind_of?(Array).should == true
    all_commands.each do |cmd|
      cmds_loaded.delete(cmd).should == cmd
    end
    cmds_loaded.size.should == 0
  end
end
