require 'spec/helper'
require "fsr/app"
FSR::App.load_application("break")

describe "Testing FSR::App::FsBreak" do

  it "should break a connection" do
    fs_break = FSR::App::FsBreak.new
    fs_break.sendmsg.should == "call-command: execute\nexecute-app-name: answer\n\n"
  end

end
