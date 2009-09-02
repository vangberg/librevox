require 'spec/helper'
require "fsr/app"
FSR::App.load_application("app")

describe "Testing FSR::App::App" do
  it "executes arbitrary app with one argument" do
    log = FSR::App::App.new("att_xfer", "sofia/user/1")
    log.sendmsg.should == "call-command: execute\nexecute-app-name: att_xfer\nexecute-app-arg: sofia/user/1\n\n"
  end

  it "executes arbitrary app with multiple argument" do
    log = FSR::App::App.new("log", "INFO", "foo bar")
    log.sendmsg.should == "call-command: execute\nexecute-app-name: log\nexecute-app-arg: INFO foo bar\n\n"
  end
end
