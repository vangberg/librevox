require 'spec/helper'
require 'fsr/cmd'
require 'fsr/command_socket'

class SampleCmd < FSR::Cmd::Command
  def self.cmd_name; "sample_cmd" end
end

describe FSR::Cmd::Command do
  before do
    @cmd = FSR::Cmd::Command.new
  end

  should "have default command" do
    @cmd.raw.should.should == "api command"
  end

  should "use #cmd_name as command name" do
    def @cmd.cmd_name; "foo_cmd" end

    @cmd.raw.should == "api foo_cmd"
  end

  should "send arguments" do
    def @cmd.arguments; ["bar", "baz"] end

    @cmd.raw.should == "api command bar baz"
  end

  should "have background switch" do
    @cmd.background = true

    @cmd.raw.should == "bgapi command"
  end

  should "get/set response" do
    @cmd.response = 123
    @cmd.response.should == 123
  end

  describe "register" do
    should "add command to CommandSocket" do
      socket = FSR::CommandSocket.new

      socket.should.not.respond_to? :sample_cmd
      FSR::Cmd.register(SampleCmd)
      socket.should.respond_to? :sample_cmd
    end
  end
end
