require 'spec/helper'
require 'spec/librevox/listener'

require 'librevox/listener/outbound'

module Librevox::Applications
  def sample_app(name, *args, &b)
    execute_app name, args.join(" "), &b
  end
end

class OutboundTestListener < Librevox::Listener::Outbound
  session do
    send_data "session was initiated"
  end
end

def receive_event_and_linger_replies
  @listener.receive_data("Content-Type: command/reply\nReply-Text: +OK Events Enabled\n\n")
  @listener.receive_data("Content-Type: command/reply\nReply-Text: +OK will linger\n\n")
end

describe "Outbound listener" do
  before do
    @listener = OutboundTestListener.new(nil)
    @listener.receive_data("Content-Type: command/reply\nCaller-Caller-ID-Number: 8675309\n\n")
    receive_event_and_linger_replies
  end

  should "connect to freeswitch and subscribe to events" do
    @listener.outgoing_data.shift.should.equal "connect\n\n"
    @listener.outgoing_data.shift.should.equal "myevents\n\n"
    @listener.outgoing_data.shift.should.equal "linger\n\n"
  end

  should "establish a session" do
    @listener.session.class.should.equal Librevox::Response
  end

  should "call session callback after establishing new session" do
    @listener.read_data.should.equal "session was initiated"
  end

  should "make channel variables available through session" do
    @listener.session.headers[:caller_caller_id_number].should.equal "8675309"
  end

  behaves_like "events"
  behaves_like "api commands"

  should "register app" do
    @listener.respond_to?(:sample_app).should.be.true?
  end
end

class OutboundListenerWithNestedApps < Librevox::Listener::Outbound
  session do
    sample_app "foo" do
      sample_app "bar"
    end
  end
end

describe "Outbound listener with apps" do
  before do
    @listener = OutboundListenerWithNestedApps.new(nil)

    # Establish session and get rid of connect-string
    @listener.receive_data("Content-Type: command/reply\nEstablish-Session: OK\n\n")
    receive_event_and_linger_replies
    3.times {@listener.outgoing_data.shift}
  end

  should "only send one app at a time" do
    @listener.read_data.should == "sendmsg\ncall-command: execute\nexecute-app-name: foo\n\n"
    @listener.read_data.should == nil

    @listener.receive_data("Content-Type: command/reply\nReply-Text: +OK\n\n")
    @listener.read_data.should == "sendmsg\ncall-command: execute\nexecute-app-name: bar\n\n"
    @listener.read_data.should == nil
  end

  should "not be driven forward by events" do
    @listener.read_data # sample_app "foo"
    @listener.receive_data("Content-Type: command/reply\nContent-Length: 45\n\nEvent-Name: CHANNEL_EXECUTE\nSession-Var: Some\n\n")
    @listener.read_data.should == nil
  end

  should "not be driven forward by api responses" do
    @listener.read_data # sample_app "foo"
    @listener.receive_data("Content-Type: api/response\nContent-Length: 3\n\nFoo")
    @listener.read_data.should == nil
  end

  should "not be driven forward by disconnect notifications" do
    @listener.read_data # sample_app "foo"
    @listener.receive_data("Content-Type: text/disconnect-notice\nContent-Length: 9\n\nLingering")
    @listener.read_data.should == nil
  end
end

module Librevox::Applications
  def reader_app(&b)
    execute_app 'reader_app', [], {:read_var => 'a_reader_var'}, &b
  end
end

class OutboundListenerWithReader < Librevox::Listener::Outbound
  session do
    reader_app do |data|
      send_data "read this: #{data}"
    end
  end
end

describe "Outbound listener with app reading data" do
  before do
    @listener = OutboundListenerWithReader.new(nil)

    # Establish session and get rid of connect-string
    @listener.receive_data("Content-Type: command/reply\nSession-Var: First\nUnique-ID: 1234\n\n")
    receive_event_and_linger_replies
    3.times {@listener.outgoing_data.shift}
  end

  should "not send anything while missing response" do
    @listener.read_data # the command executing reader_app
    @listener.read_data.should == nil
  end

  should "send uuid_dump to get channel var, after getting response" do
    @listener.receive_data("Content-Type: command/reply\nReply-Text: +OK\n\n")
    @listener.read_data.should == "api uuid_dump 1234\n\n"
  end

  should "update session with new data" do
    @listener.receive_data("Content-Type: command/reply\nContent-Length: 3\n\n+OK\n\n")
    @listener.receive_data("Content-Type: command/reply\nContent-Length: 44\n\nEvent-Name: CHANNEL_DATA\nSession-Var: Second\n\n")
    @listener.session.content[:session_var].should == "Second"
  end

  should "pass value of channel variable to block" do
    @listener.receive_data("Content-Type: command/reply\nContent-Length: 3\n\n+OK\n\n")
    @listener.receive_data("Content-Type: command/reply\nContent-Length: 59\n\nEvent-Name: CHANNEL_DATA\nvariable_a-reader-var: some value\n\n")
    @listener.read_data.should == "read this: some value"
  end
end

class OutboundListenerWithNonNestedApps < Librevox::Listener::Outbound
  attr_reader :queue
  session do
    sample_app "foo"
    reader_app do |data|
      send_data "the end: #{data}"
    end
  end
end

describe "Outbound listener with non-nested apps" do
  before do
    @listener = OutboundListenerWithNonNestedApps.new(nil)

    # Establish session and get rid of connect-string
    @listener.receive_data("Content-Type: command/reply\nSession-Var: First\nUnique-ID: 1234\n\n")
    receive_event_and_linger_replies
    3.times {@listener.outgoing_data.shift}
  end

  should "wait for response before calling next proc" do
    # response to sample_app
    @listener.read_data.should.not.match /the end/
    @listener.receive_data("Content-Type: command/reply\nContent-Length: 3\n\n+OK\n\n")

    # response to reader_app
    @listener.read_data.should.not.match /the end/
    @listener.receive_data("Content-Type: command/reply\nContent-Length: 3\n\n+OK\n\n")

    # response to uuid_dump caused by reader_app
    @listener.read_data.should.not.match /the end/
    @listener.receive_data("Content-Type: command/reply\nContent-Length: 59\n\nEvent-Name: CHANNEL_DATA\nvariable_a-reader-var: some value\n\n")

    @listener.read_data.should == "the end: some value"
  end
end

module Librevox::Commands
  def sample_cmd(cmd, *args, &b)
    execute_cmd cmd, *args, &b
  end
end

class OutboundListenerWithAppsAndApi < Librevox::Listener::Outbound
  session do
    sample_app "foo" do
      sample_cmd "bar" do
        sample_app "baz"
      end
    end
  end
end

describe "Outbound listener with both apps and api calls" do
  before do
    @listener = OutboundListenerWithAppsAndApi.new(nil)

    # Establish session and get rid of connect-string
    @listener.receive_data("Content-Type: command/reply\nSession-Var: First\nUnique-ID: 1234\n\n")
    receive_event_and_linger_replies
    3.times {@listener.outgoing_data.shift}
  end

  should "wait for response before calling next proc" do
    @listener.read_data.should == "sendmsg\ncall-command: execute\nexecute-app-name: foo\n\n"
    @listener.receive_data("Content-Type: command/reply\nContent-Length: 3\n\n+OK\n\n")

    @listener.read_data.should == "api bar\n\n"
    @listener.receive_data("Content-Type: api/response\nContent-Length: 3\n\n+OK\n\n")

    @listener.read_data.should == "sendmsg\ncall-command: execute\nexecute-app-name: baz\n\n"
  end
end
