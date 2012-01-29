require './spec/helper'
require 'librevox/listener/base'

include Librevox::Test::ListenerHelpers

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

# These tests are a bit fragile, as they depend on event hooks being
# executed before on_event.
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
    @class.hooks.each do |event, hooks|
      hooks.size.should == 1
    end
  end

  should "execute callback for event" do
    event "OTHER_EVENT"
    @listener.read_data.should == "something else"

    event "SOME_EVENT"
    @listener.read_data.should == "something"
  end

  should "pass response duplicate as arg to hook block" do
    event "HOOK_WITH_ARG"

    reply = @listener.read_data
    reply.should =~ /^got event arg: /
    reply.should.not =~ /^got event arg: #{@listener.response.object_id}$/
  end

  should "expose response as event" do
    event "OTHER_EVENT"

    @listener.event.class.should == Librevox::Response
    @listener.event.content[:event_name].should == "OTHER_EVENT"
  end

  should "call on_event" do
    event "THIRD_EVENT"

    @listener.read_data.should =~ /^from on_event/
  end

  should "call on_event with response duplicate as argument" do
    event "THIRD_EVENT"

    @listener.read_data.should.not =~ /^from on_event: #{@listener.response.object_id}$/
  end

  should "call event hooks and on_event on CHANNEL_DATA" do
    @listener.outgoing_data.clear

    def @listener.on_event e
      send_data "on_event: CHANNEL_DATA test"
    end
    @class.event(:channel_data) {send_data "event hook: CHANNEL_DATA test"}

    event "CHANNEL_DATA"

    @listener.outgoing_data.should.include "on_event: CHANNEL_DATA test"
    @listener.outgoing_data.should.include "event hook: CHANNEL_DATA test"
  end
end

module Librevox::Commands
  def sample_cmd cmd, args="", &block
    command cmd, args, &block
  end
end

shared "api commands" do
  before do
    @class = @listener.class

    # Establish session
    command_reply "Test" => "Testing"
  end

  describe "multiple api commands" do
    extend Librevox::Test::Matchers

    before do
      @listener.outgoing_data.clear

      def @listener.on_event(e) end # Don't send anything, kthx.

      @class.event(:api_test) {
        api.sample_cmd "foo" do
          api.sample_cmd "foo", "bar baz" do |r|
            command "response #{r.content}"
          end
        end
      }
    end

    should "only send one command at a time, and return response for commands" do
      command_reply :body => {"Event-Name" => "API_TEST"}
      @listener.should send_command "api foo"
      @listener.should send_nothing

      api_response "Reply-Text" => "+OK"
      @listener.should send_command "api foo bar baz"
      @listener.should send_nothing

      api_response :body => "+YAY"
      @listener.should send_command "response +YAY"
    end
  end
end
