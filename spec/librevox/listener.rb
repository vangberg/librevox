require 'spec/helper'

require 'librevox/listener/base'

class Librevox::Listener::Base
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

    @class.event(:some_event) {send_data "something"}
    @class.event(:other_event) {send_data "something else"}
    @class.event(:hook_with_arg) {|e| send_data "got event arg: #{e.object_id}"}

    def @listener.on_event(e)
      send_data "from on_event: #{e.object_id}"
    end

    # Establish session
    @listener.receive_data("Content-Length: 0\nTest: Testing\n\n")
  end

  should "add event hook" do
    @class.hooks.size.should == 3
  end

  should "execute callback for event" do
    @listener.receive_data("Content-Length: 23\n\nEvent-Name: OTHER_EVENT\n\n")
    @listener.read_data.should == "something else"

    @listener.receive_data("Content-Length: 22\n\nEvent-Name: SOME_EVENT\n\n")
    @listener.read_data.should == "something"
  end

  should "pass response duplicate as arg to hook block" do
    @listener.receive_data("Content-Length: 25\n\nEvent-Name: HOOK_WITH_ARG\n\n")
    reply = @listener.read_data
    reply.should =~ /^got event arg: /
    reply.should.not =~ /^got event arg: #{@listener.response.object_id}$/
  end

  should "expose response as event" do
    @listener.receive_data("Content-Length: 23\n\nEvent-Name: OTHER_EVENT\n\n")
    @listener.event.class.should == Librevox::Response
    @listener.event.content[:event_name].should == "OTHER_EVENT"
  end

  should "call on_event" do
    @listener.receive_data("Content-Length: 23\n\nEvent-Name: THIRD_EVENT\n\n")
    @listener.read_data.should =~ /^from on_event/
  end

  should "call on_event with response duplicate as argument" do
    @listener.receive_data("Content-Length: 23\n\nEvent-Name: THIRD_EVENT\n\n")
    @listener.read_data.should.not =~ /^from on_event: #{@listener.response.object_id}$/
  end
end

module Librevox::Commands
  def sample_cmd(cmd, args="", &b)
    command cmd, args, &b
  end
end

shared "api commands" do
  before do
    @class = @listener.class

    # Establish session
    @listener.receive_data("Content-Type: command/reply\nTest: Testing\n\n")
  end

  describe "multiple api commands" do
    before do
      @listener.outgoing_data.clear

      def @listener.on_event(e) end # Don't send anything, kthx.

      @class.event(:api_test) {
        api :sample_cmd, "foo" do
          api :sample_cmd, "foo", "bar baz"
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
      @class.event(:api_flat_test) {
        api :sample_cmd, "foo"
        api :sample_cmd, "bar" do
          api :sample_cmd, "baz"
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
      @class.event(:api_arg_test) {
        api :sample_cmd, "foo" do |r|
          send_data "response: #{r.content}"
        end
      }
    end

    should "pass response" do
      @listener.receive_data("Content-Type: command/reply\nContent-Length: 26\n\nEvent-Name: API_ARG_TEST\n\n")
      @listener.receive_data("Content-Type: api/response\nContent-Length: 3\n\n+OK\n\n")

      @listener.read_data.should == "response: +OK"
    end
  end
end
