require 'spec/helper'
require "fsr/app"
FSR::App.load_application("play_and_get_digits")

describe "Testing FSR::App::PlayAndGetDigits" do
  # Utilize the [] shortcut to start a conference
  it "Send a play_and_gets_digits command" do
    tmp = FSR::App::PlayAndGetDigits.new("soundfile.wav", "invalid.wav")
    tmp.sendmsg.should == "call-command: execute\nexecute-app-name: play_and_get_digits\nexecute-app-arg: 0 10 3 7000 # soundfile.wav invalid.wav fsr_read_dtmf d\nevent-lock:true\n\n"
  end

end
