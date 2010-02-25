require 'spec/helper'
require 'rr'
require 'mocksocket'

require 'librevox/command_socket'

class Bacon::Context
  include RR::Adapters::RRMethods
end

module Librevox
  module Commands
    def sample_cmd args=""
      execute_cmd "sample_cmd", args
    end
  end
end

describe Librevox::CommandSocket do
  before do
    @socket, @server = MockSocket.pipe
    mock(TCPSocket).open(anything, anything).times(any_times) {@socket}

    @server.print "Content-Type: command/reply\nReply-Text: +OK\n\n"
  end

  # This should be tested with some mocks. How do we use rr + bacon?
  describe ":connect => false" do
    should "not connect" do
      @cmd = Librevox::CommandSocket.new(:connect => false)
      @server.should.be.empty?
    end

    should "connect when asked" do
      @cmd.connect
      @server.gets.should == "auth ClueCon\n"
    end
  end

  describe "with auto-connect" do
    before do
      @cmd = Librevox::CommandSocket.new
    end

    should "authenticate" do
      @server.gets.should == "auth ClueCon\n"
    end

    should "read header response" do
      @server.print "Content-Type: command/reply\nSome-Header: Some value\n\n"
      reply = @cmd.run_cmd "foo"

      reply.class.should == Librevox::Response
      reply.headers[:some_header].should == "Some value"
    end

    should "read command/reply responses" do
      @server.print "Content-Type: api/log\nSome-Header: Old data\n\n"

      @server.print "Content-Type: command/reply\nSome-Header: New data\n\n"
      reply = @cmd.run_cmd "foo"

      reply.headers[:some_header].should == "New data"
    end

    should "read api/response responses" do
      @server.print "Content-Type: api/log\nSome-Header: Old data\n\n"

      @server.print "Content-Type: api/response\nSome-Header: New data\n\n"
      reply = @cmd.run_cmd "foo"

      reply.headers[:some_header].should == "New data"
    end

    should "read content if present" do
      @server.print "Content-Type: command/reply\nContent-Length: 3\n\n+OK\n\n"
      reply = @cmd.run_cmd "foo"

      reply.content.should == "+OK"
    end

    should "register command" do
      @cmd.should.respond_to? :sample_cmd
    end

    describe "registered" do
      before do
        2.times {@server.gets} # get rid of the auth message
      end

      should "send command" do
        @server.print "Content-Type: command/reply\nContent-Length: 3\n\n+OK\n\n"
        @cmd.sample_cmd
        @server.gets.should == "api sample_cmd\n"
      end

      should "return response from command" do
        @server.print "Content-Type: command/reply\nContent-Length: 3\n\n+OK\n\n"
        response = @cmd.sample_cmd
        response.class.should == Librevox::Response
        response.content.should == "+OK"
      end

      should "pass arguments" do
        @server.print "Content-Type: command/reply\nContent-Length: 3\n\n+OK\n\n"
        @cmd.sample_cmd("foo bar")
        @server.gets.should == "api sample_cmd foo bar\n"
      end
    end
  end
end
