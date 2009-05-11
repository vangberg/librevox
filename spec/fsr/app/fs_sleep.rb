require 'spec/helper'
require "fsr/app"
FSR::App.load_application("fs_sleep")

describe "Testing FSR::App::FsSleep" do

  it "should put FreeSWITCH leg to sleep" do
    fs_sleep = FSR::App::FSSleep.new
    fs_sleep.sendmsg.should == "call-command: execute\nexecute-app-name: break\n\n"
  end

end
