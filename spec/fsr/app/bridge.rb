require 'spec/helper'
require "fsr/app"

describe "Testing FSR::App::Bridge" do
  should "bridge a call with single endpoint" do
      bridge = FSR::App::Bridge.new("user/bougyman")
      bridge.sendmsg.should == "call-command: execute\nexecute-app-name: bridge\nexecute-app-arg: user/bougyman\n\n"
  end

  should "bridge a call with multiple simultaneous endpoints" do
    bridge = FSR::App::Bridge.new("user/bougyman", "user/coltrane")
    bridge.sendmsg.should == "call-command: execute\nexecute-app-name: bridge\nexecute-app-arg: user/bougyman,user/coltrane\n\n"
  end
  
  should "bridge a call with multiple sequential endpoints" do
    bridge = FSR::App::Bridge.new("user/bougyman", "user/coltrane", :sequential => true)
    bridge.sendmsg.should == "call-command: execute\nexecute-app-name: bridge\nexecute-app-arg: user/bougyman|user/coltrane\n\n"
  end
end
