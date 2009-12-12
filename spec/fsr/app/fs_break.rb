require 'spec/helper'
require 'fsr/app'

describe FSR::App::FSBreak do
  should "cancel an application" do
    fs_break = FSR::App::FSBreak.new
    fs_break.sendmsg.should == "call-command: execute\nexecute-app-name: break\n\n"
  end

  should "cancel all applications" do
    fs_break = FSR::App::FSBreak.new(:all => true)
    fs_break.sendmsg.should == "call-command: execute\nexecute-app-name: break\nexecute-app-arg: all\n\n"
  end
end
