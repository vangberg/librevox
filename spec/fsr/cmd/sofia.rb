require 'spec/helper'
require "fsr/cmd"
FSR::Cmd.load_command("sofia")

describe "Testing FSR::Cmd::Sofia" do
  # Interface to sofia
  it "FSR::Cmd::Sofia should interface to sofia" do
    sofia = FSR::Cmd::Sofia.new
    sofia.raw.should == "sofia"
  end
  # Sofia status
  it "FSR::Cmd::Sofia should allow status" do
    sofia = FSR::Cmd::Sofia.new
    status = sofia.status
    status.raw.should == "sofia status"
  end
  # Sofia status profile internal
  it "FSR::Cmd::Sofia should allow status profile internal" do
    sofia = FSR::Cmd::Sofia.new
    status = sofia.status(:status => 'profile', :name => 'internal')
    status.raw.should == "sofia status profile internal"
  end
  # Sofia status gateway server 
  it "FSR::Cmd::Sofia should allow status gateway server" do
    sofia = FSR::Cmd::Sofia.new
    status = sofia.status(:status => 'gateway', :name => 'server')
    status.raw.should == "sofia status gateway server"
  end


end
