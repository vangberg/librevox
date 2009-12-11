require 'spec/helper'
require 'fsr/cmd'

describe FSR::Cmd::Reload do
  should "reload module" do
    cmd = FSR::Cmd::Reload.new("some_mod")
    cmd.raw.should == "api reload some_mod"
  end

  should "force reload module" do
    cmd = FSR::Cmd::Reload.new("some_mod", :force => true)
    cmd.raw.should == "api reload -f some_mod"
  end
end
