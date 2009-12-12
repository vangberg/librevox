require 'spec/helper'
require "fsr/app"

describe FSR::App::FSSleep do
  should "pause the channel" do
    fs_sleep = FSR::App::FSSleep.new(7000)
    fs_sleep.sendmsg.should == "call-command: execute\nexecute-app-name: sleep\nexecute-app-arg: 7000\n\n"
  end

end
