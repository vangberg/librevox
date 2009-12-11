require 'spec/helper'
require 'rr'
require 'mocksocket'
require 'fsr/command_socket'

class Bacon::Context
  include RR::Adapters::RRMethods
end

class SampleCmd < FSR::Cmd::Command
  def self.cmd_name
    "sample_cmd"
  end

  def response=(data)
    @response = "From command: #{data.content}"
  end
end

describe FSR::CommandSocket do
  before do
    @socket, @server = MockSocket.pipe
    stub(TCPSocket).open(anything, anything).times(any_times) {@socket}

    @server.print "Content-Type: command/reply\nReply-Text: +OK\n\n"
    @cmd = FSR::CommandSocket.new
  end

  should "authenticate" do
    @server.gets.should == "auth ClueCon\n"
  end

  should "read header response" do
    @server.print "Content-Type: command/reply\nSome-Header: Some value\n\n"
    reply = @cmd.command "foo"

    reply.class.should == FSR::Response
    reply.headers[:some_header].should == "Some value"
  end

  should "read command/reply responses" do
    @server.print "Content-Type: api/log\nSome-Header: Old data\n\n"

    @server.print "Content-Type: command/reply\nSome-Header: New data\n\n"
    reply = @cmd.command "foo"

    reply.headers[:some_header].should == "New data"
  end

  should "read api/response responses" do
    @server.print "Content-Type: api/log\nSome-Header: Old data\n\n"

    @server.print "Content-Type: api/response\nSome-Header: New data\n\n"
    reply = @cmd.command "foo"

    reply.headers[:some_header].should == "New data"
  end

  should "read content if present" do
    @server.print "Content-Type: command/reply\nContent-Length: 3\n\n+OK\n\n"
    reply = @cmd.command "foo"

    reply.content.should == "+OK"
  end

  should "register command" do
    @cmd.should.not.respond_to? :sample_cmd
    FSR::CommandSocket.register_cmd SampleCmd
    @cmd.should.respond_to? :sample_cmd
  end

  describe "with commands" do
    before do
      FSR::CommandSocket.register_cmd SampleCmd
      2.times {@server.gets} # get rid of the auth message
    end

    should "send command" do
      @server.print "Content-Type: command/reply\nContent-Length: 3\n\n+OK\n\n"
      @cmd.sample_cmd
      @server.gets.should == "api sample_cmd\n"
    end

    should "return response from command" do
      @server.print "Content-Type: command/reply\nContent-Length: 3\n\n+OK\n\n"
      @cmd.sample_cmd.should == "From command: +OK"
    end
  end
end
