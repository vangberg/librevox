require 'spec/helper'
require "fsr/app"
FSR::App.load_application("playback")

describe "Testing FSR::App::Playback" do
  it "Plays a file or stream" do
    playback = FSR::App::Playback.new("shout://scfire-ntc-aa01.stream.aol.com/stream/1035")
    playback.sendmsg.should == "call-command: execute\nexecute-app-name: playback\nexecute-app-arg: shout://scfire-ntc-aa01.stream.aol.com/stream/1035\nevent-lock:true\n\n"
  end

end
