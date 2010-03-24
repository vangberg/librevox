require 'spec/helper'
require 'spec/librevox/listener'

require 'librevox/listener/outbound'

module Librevox::Applications
  def sample_app name, *args
    application name, args.join(" ")
  end
end

class OutboundTestListener < Librevox::Listener::Outbound
  def session_initiated
    send_data "session was initiated"
  end
end

def receive_event_and_linger_replies
  @listener.command_reply "Reply-Text" => "+OK Events Enabled"
  @listener.command_reply "Reply-Text" => "+OK will linger"
end

describe "Outbound listener" do
  extend Librevox::Matchers::Outbound

  before do
    @listener = OutboundTestListener.new(nil)
    @listener.receive_data("Content-Type: command/reply\nCaller-Caller-ID-Number: 8675309\nvariable_some_var: some value\n\n")
    receive_event_and_linger_replies
  end

  should "connect to freeswitch and subscribe to events" do
    @listener.should send_command "connect"
    @listener.should send_command "myevents"
    @listener.should send_command "linger"
  end

  should "establish a session" do
    @listener.session.class.should.equal Hash
  end

  should "call session callback after establishing new session" do
    @listener.outgoing_data.pop.should == "session was initiated"
  end

  should "make headers available through session" do
    @listener.session[:caller_caller_id_number].should.equal "8675309"
  end

  should "make channel variables available through #variable" do
    @listener.variable(:some_var).should == "some value"
  end

  behaves_like "events"
  behaves_like "api commands"
end

class OutboundListenerWithNestedApps < Librevox::Listener::Outbound
  def session_initiated
    sample_app "foo"
    sample_app "bar"
  end
end

describe "Outbound listener with apps" do
  extend Librevox::Matchers::Outbound

  before do
    @listener = OutboundListenerWithNestedApps.new(nil)

    # Establish session and get rid of connect-string
    @listener.receive_data("Content-Type: command/reply\nEstablish-Session: OK\n\n")
    receive_event_and_linger_replies
    3.times {@listener.outgoing_data.shift}
  end

  should "only send one app at a time" do
    @listener.should send_application "foo"
    @listener.should send_nothing

    @listener.receive_data("Content-Type: command/reply\nReply-Text: +OK\n\n")

    @listener.should send_application "bar"
    @listener.should send_nothing
  end

  should "not be driven forward by events" do
    @listener.should send_application "foo"
    @listener.receive_data("Content-Type: command/reply\nContent-Length: 45\n\nEvent-Name: CHANNEL_EXECUTE\nSession-Var: Some\n\n")
    @listener.should send_nothing
  end

  should "not be driven forward by api responses" do
    @listener.should send_application "foo"
    @listener.receive_data("Content-Type: api/response\nContent-Length: 3\n\nFoo")
    @listener.should send_nothing
  end

  should "not be driven forward by disconnect notifications" do
    @listener.should send_application "foo"
    @listener.receive_data("Content-Type: text/disconnect-notice\nContent-Length: 9\n\nLingering")
    @listener.should send_nothing
  end
end

module Librevox::Applications
  def reader_app
    application 'reader_app', "", {:variable => 'app_var'}
  end
end

class OutboundListenerWithReader < Librevox::Listener::Outbound
  def session_initiated
    data = reader_app
    application "send", data
  end
end

describe "Outbound listener with app reading data" do
  extend Librevox::Matchers::Outbound

  before do
    @listener = OutboundListenerWithReader.new(nil)

    # Establish session and get rid of connect-string
    @listener.receive_data("Content-Type: command/reply\nSession-Var: First\nUnique-ID: 1234\n\n")
    receive_event_and_linger_replies
    3.times {@listener.outgoing_data.shift}

    @listener.should send_application "reader_app"
  end

  should "not send anything while missing response" do
    @listener.should send_nothing
  end

  should "send uuid_dump to get channel var, after getting response" do
    @listener.receive_data("Content-Type: command/reply\nReply-Text: +OK\n\n")
    @listener.should update_session 1234
  end

  should "update session with new data" do
    @listener.receive_data("Content-Type: command/reply\nContent-Length: 3\n\n+OK\n\n")
    @listener.should update_session 1234
    @listener.receive_data("Content-Type: api/response\nContent-Length: 44\n\nEvent-Name: CHANNEL_DATA\nSession-Var: Second\n\n")
    @listener.session[:session_var].should == "Second"
  end

  should "return value of channel variable" do
    @listener.receive_data("Content-Type: command/reply\nContent-Length: 3\n\n+OK\n\n")
    @listener.should update_session 1234
    @listener.receive_data("Content-Type: api/response\nContent-Length: 50\n\nEvent-Name: CHANNEL_DATA\nvariable_app_var: Second\n\n")
    @listener.should send_application "send", "Second"
  end
end

class OutboundListenerWithNonNestedApps < Librevox::Listener::Outbound
  attr_reader :queue
  def session_initiated
    sample_app "foo"
    data = reader_app
    application "send", "the end: #{data}"
  end
end

describe "Outbound listener with non-nested apps" do
  extend Librevox::Matchers::Outbound

  before do
    @listener = OutboundListenerWithNonNestedApps.new(nil)

    # Establish session and get rid of connect-string
    @listener.receive_data("Content-Type: command/reply\nSession-Var: First\nUnique-ID: 1234\n\n")
    receive_event_and_linger_replies
    3.times {@listener.outgoing_data.shift}
  end

  should "wait for response before calling next proc" do
    @listener.should send_application "foo"
    @listener.receive_data("Content-Type: command/reply\nContent-Length: 3\n\n+OK\n\n")

    @listener.should send_application "reader_app"
    @listener.receive_data("Content-Type: command/reply\nContent-Length: 3\n\n+OK\n\n")

    @listener.should update_session
    @listener.receive_data("Content-Type: api/response\nContent-Length: 50\n\nEvent-Name: CHANNEL_DATA\nvariable_app_var: Second\n\n")

    @listener.should send_application "send", "the end: Second"
  end
end

module Librevox::Commands
  def sample_cmd cmd, *args
    command cmd, *args
  end
end

class OutboundListenerWithAppsAndApi < Librevox::Listener::Outbound
  def session_initiated
    sample_app "foo"
    api.sample_cmd "bar"
    sample_app "baz"
  end
end

describe "Outbound listener with both apps and api calls" do
  extend Librevox::Matchers::Outbound

  before do
    @listener = OutboundListenerWithAppsAndApi.new(nil)

    # Establish session and get rid of connect-string
    @listener.receive_data("Content-Type: command/reply\nSession-Var: First\nUnique-ID: 1234\n\n")
    receive_event_and_linger_replies
    3.times {@listener.outgoing_data.shift}
  end

  should "wait for response before calling next proc" do
    @listener.should send_application "foo"
    @listener.receive_data("Content-Type: command/reply\nContent-Length: 3\n\n+OK\n\n")

    @listener.should send_command "api bar"
    @listener.receive_data("Content-Type: api/response\nContent-Length: 3\n\n+OK\n\n")

    @listener.should send_application "baz"
  end
end

class OutboundListenerWithUpdateSessionCallback < Librevox::Listener::Outbound
  def session_initiated
    update_session
    application "send", "yay, #{session[:session_var]}"
  end
end

describe "Outbound listener with update session callback" do
  extend Librevox::Matchers::Outbound

  before do
    @listener = OutboundListenerWithUpdateSessionCallback.new(nil)
    @listener.receive_data("Content-Type: command/reply\nSession-Var: First\nUnique-ID: 1234\n\n")
    receive_event_and_linger_replies
    3.times {@listener.outgoing_data.shift}

    @listener.should update_session
    @listener.receive_data("Content-Type: api/response\nContent-Length: 44\n\nEvent-Name: CHANNEL_DATA\nSession-Var: Second\n\n")
  end

  should "execute callback" do
    @listener.read_data.should =~ /yay,/
  end

  should "update session before calling callback" do
    @listener.should send_application "send", "yay, Second"
  end
end
