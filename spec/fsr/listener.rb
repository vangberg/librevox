require 'spec/helper'
require 'fsr/listener'
require 'fsr/app'

include FSR

class Listener::Base
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
    @listener.event.class.should == FSR::Listener::Response
    @listener.event.content[:event_name].should == "OTHER_EVENT"
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
      @class.add_event_hook(:API_TEST) {
        api "foo" do
          api "foo", "bar", "baz"
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
        api "foo"
        api "bar" do
          api "baz"
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
        api "foo" do |r|
          send_data "response: #{r}"
        end
      }
    end
    
    should "wait for response before calling next proc" do
      @listener.receive_data("Content-Type: command/reply\nContent-Length: 26\n\nEvent-Name: API_ARG_TEST\n\n")
      @listener.receive_data("Content-Type: api/response\nContent-Length: 3\n\n+OK\n\n")

      @listener.read_data.should == "response: +OK"
    end
  end
end

# Stupid hack. How do we make bacon ignore this file?
describe "Listener" do
  should "have empty spec" do
    true.should.be.true?
  end
end
