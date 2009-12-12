require 'spec/helper'
require 'fsr/listener'
require 'fsr/app'

include FSR

class FSR::Listener::Base
  attr_accessor :outgoing_data

  def initialize(*args)
    @outgoing_data = []
    super *args
  end

  def send_data(data)
    @outgoing_data << data
  end

  def read_data
    @outgoing_data.pop
  end
end

shared "events" do
  before do
    @class = @listener.class

    @class.add_event_hook(:SOME_EVENT) {send_data "something"}
    @class.add_event_hook(:OTHER_EVENT) {send_data "something else"}

    # Establish session
    @listener.receive_data("Content-Length: 0\nTest: Testing\n\n")
  end

  should "add event hook" do
    @class.hooks.size.should == 2
  end

  should "execute callback for event" do
    @listener.receive_data("Content-Length: 23\n\nEvent-Name: OTHER_EVENT\n\n")
    @listener.read_data.should == "something else"

    @listener.receive_data("Content-Length: 22\n\nEvent-Name: SOME_EVENT\n\n")
    @listener.read_data.should == "something"
  end

  should "expose response as event" do
    @listener.receive_data("Content-Length: 23\n\nEvent-Name: OTHER_EVENT\n\n")
    @listener.event.class.should == FSR::Response
    @listener.event.content[:event_name].should == "OTHER_EVENT"
  end
end

class SampleCmd < FSR::Cmd::Command
  def self.cmd_name
    "sample_cmd"
  end

  attr_reader :cmd_name, :arguments

  def initialize(cmd, *args)
    @cmd_name, @arguments = cmd, args
  end

  def response=(r)
    @response = "from command: #{r.content}"
  end
end

shared "api commands" do
  before do
    @class = @listener.class

    # Establish session
    @listener.receive_data("Content-Type: command/reply\nTest: Testing\n\n")
  end

  should "register command" do
    @listener.should.not.respond_to? :sample_cmd

    FSR::Listener::Base.register_cmd(SampleCmd)

    @listener.should.respond_to? :sample_cmd
  end

  describe "with registered command" do
    before do
      FSR::Listener::Base.register_cmd(SampleCmd)
    end

    describe "multiple api commands" do
      before do
        @listener.outgoing_data.clear
        @class.add_event_hook(:API_TEST) {
          sample_cmd "foo" do
            sample_cmd "foo", "bar", "baz"
          end
        }
      end

      should "only send one command at a time" do
        @listener.receive_data("Content-Type: command/reply\nContent-Length: 22\n\nEvent-Name: API_TEST\n\n")
        @listener.read_data.should == "api foo\n\n"
        @listener.read_data.should == nil

        @listener.receive_data("Content-Type: api/response\nReply-Text: +OK\n\n")
        @listener.read_data.should == "api foo bar baz\n\n"
        @listener.read_data.should == nil
      end
    end

    describe "flat api commands" do
      before do
        @listener.outgoing_data.clear
        @class.add_event_hook(:API_FLAT_TEST) {
          sample_cmd "foo"
          sample_cmd "bar" do
            sample_cmd "baz"
          end
        }
      end

      should "wait for response before calling next proc" do
        @listener.receive_data("Content-Type: command/reply\nContent-Length: 27\n\nEvent-Name: API_FLAT_TEST\n\n")

        @listener.read_data.should.not == "api baz\n\n"

        # response to "foo"
        @listener.receive_data("Content-Type: api/response\nContent-Length: 3\n\n+OK\n\n")
        @listener.read_data.should.not == "api baz\n\n"

        # response to "bar"
        @listener.receive_data("Content-Type: api/response\nContent-Length: 3\n\n+OK\n\n")
        @listener.read_data.should == "api baz\n\n"
      end
    end

    describe "api command with block argument" do
      before do
        @listener.outgoing_data.clear
        @class.add_event_hook(:API_ARG_TEST) {
          sample_cmd "foo" do |r|
            send_data "response: #{r}"
          end
        }
      end

      should "pass response from command" do
        @listener.receive_data("Content-Type: command/reply\nContent-Length: 26\n\nEvent-Name: API_ARG_TEST\n\n")
        @listener.receive_data("Content-Type: api/response\nContent-Length: 3\n\n+OK\n\n")

        @listener.read_data.should == "response: from command: +OK"
      end
    end
  end
end

# Stupid hack. How do we make bacon ignore this file?
describe "Listener" do
  should "have empty spec" do
    true.should.be.true?
  end
end
