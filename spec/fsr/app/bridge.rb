require 'spec/helper'
require "fsr/app"
FSR::App.load_application("bridge")

describe "Testing FSR::App::Bridge" do
  # Utilize the [] shortcut to start a conference
  it "Bridges a call, for FSR::Listener::Inbound" do
    bridge = FSR::App::Bridge.new("user/bougyman")
    bridge.raw.should == "bridge({}user/bougyman)"
  end

  it "Bridges a call, for FSR::Listener::Outbound" do
    bridge = FSR::App::Bridge.new("user/bougyman")
    bridge.sendmsg.should == "call-command: execute\nexecute-app-name: bridge\nexecute-app-arg: user/bougyman\n\n"
  end

end
