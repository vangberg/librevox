require 'spec/helper'
require 'fsr/cmd'
require 'fsr/listener'
require 'fsr/command_socket'

class SampleCmd1 < FSR::Cmd::Command
  def self.cmd_name; "sample_cmd1" end
end

class SampleCmd2 < FSR::Cmd::Command
  def self.cmd_name; "sample_cmd2" end
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
      socket = FSR::CommandSocket.new :connect => false

      socket.should.not.respond_to? :sample_cmd1
      FSR::Cmd.register(SampleCmd1)
      socket.should.respond_to? :sample_cmd1
    end

    should "add command to Listener::Base" do
      listener = FSR::Listener::Base.new(nil)

      listener.should.not.respond_to? :sample_cmd2
      FSR::Cmd.register(SampleCmd2)
      listener.should.respond_to? :sample_cmd2
    end
  end
end
