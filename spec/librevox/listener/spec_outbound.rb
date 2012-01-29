require './spec/helper'
require './spec/librevox/listener'

require 'librevox/listener/outbound'

module Librevox::Applications
  def sample_app name, *args, &block
    application name, args.join(" "), &block
  end
end

class OutboundTestListener < Librevox::Listener::Outbound
  def session_initiated
    send_data "session was initiated"
  end
end

def event_and_linger_replies
  command_reply "Reply-Text" => "+OK Events Enabled"
  command_reply "Reply-Text" => "+OK will linger"
end

describe "Outbound listener" do
  extend Librevox::Test::Matchers

  before do
    @listener = OutboundTestListener.new(nil)
    command_reply(
      "Caller-Caller-Id-Number" => "8675309",
      "Unique-ID"               => "1234",
      "variable_some_var"       => "some value"
    )
    event_and_linger_replies
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
    sample_app "foo" do
      sample_app "bar"
    end
  end
end

describe "Outbound listener with apps" do
  extend Librevox::Test::Matchers

  before do
    @listener = OutboundListenerWithNestedApps.new(nil)

    command_reply "Establish-Session" => "OK",
                  "Unique-ID"         => "1234"
    event_and_linger_replies
    3.times {@listener.outgoing_data.shift}
  end

  should "only send one app at a time" do
    @listener.should send_application "foo"
    @listener.should send_nothing

    command_reply "Reply-Text" => "+OK"
    @listener.should update_session
    channel_data

    @listener.should send_application "bar"
    @listener.should send_nothing
  end

  should "not be driven forward by events" do
    @listener.should send_application "foo"

    command_reply :body => {
      "Event-Name"  => "CHANNEL_EXECUTE",
      "Session-Var" => "Some"
    }

    @listener.should send_nothing
  end

  should "not be driven forward by api responses" do
    @listener.should send_application "foo"

    api_response :body => "Foo"

    @listener.should send_nothing
  end

  should "not be driven forward by disconnect notifications" do
    @listener.should send_application "foo"

    response "Content-Type" => "text/disconnect-notice",
             :body          => "Lingering"

    @listener.should send_nothing
  end
end

module Librevox::Applications
  def reader_app &block
    application 'reader_app', "", {:variable => 'app_var'}, &block
  end
end

class OutboundListenerWithReader < Librevox::Listener::Outbound
  def session_initiated
    reader_app do |data|
      application "send", data
    end
  end
end

describe "Outbound listener with app reading data" do
  extend Librevox::Test::Matchers

  before do
    @listener = OutboundListenerWithReader.new(nil)

    command_reply "Session-Var" => "First",
                  "Unique-ID"   => "1234"
    event_and_linger_replies
    3.times {@listener.outgoing_data.shift}

    @listener.should send_application "reader_app"
  end

  should "not send anything while missing response" do
    @listener.should send_nothing
  end

  should "send uuid_dump to get channel var, after getting response" do
    command_reply "Reply-Text" => "+OK"
    @listener.should update_session 1234
  end

  should "update session with new data" do
    command_reply :body => "+OK"

    @listener.should update_session 1234
    api_response :body => {
      "Event-Name"  => "CHANNEL_DATA",
      "Session-Var" => "Second"
    }

    @listener.session[:session_var].should == "Second"
  end

  should "return value of channel variable" do
    command_reply :body => "+OK"

    @listener.should update_session 1234
    api_response :body => {
      "Event-Name"       => "CHANNEL_DATA",
      "variable_app_var" => "Second"
    }

    @listener.should send_application "send", "Second"
  end
end

class OutboundListenerWithNonNestedApps < Librevox::Listener::Outbound
  attr_reader :queue
  def session_initiated
    sample_app "foo" do
      reader_app do |data|
        application "send", "the end: #{data}"
      end
    end
  end
end

describe "Outbound listener with non-nested apps" do
  extend Librevox::Test::Matchers

  before do
    @listener = OutboundListenerWithNonNestedApps.new(nil)

    command_reply "Session-Var" => "First",
                  "Unique-ID"   => "1234"
    event_and_linger_replies
    3.times {@listener.outgoing_data.shift}
  end

  should "wait for response before calling next app" do
    @listener.should send_application "foo"
    command_reply :body => "+OK"
    @listener.should update_session
    channel_data "Unique-ID" => "1234"

    @listener.should send_application "reader_app"
    command_reply :body => "+OK"

    @listener.should update_session
    api_response :body => {
      "Event-Name"       => "CHANNEL_DATA",
      "variable_app_var" => "Second"
    }

    @listener.should send_application "send", "the end: Second"
  end
end

module Librevox::Commands
  def sample_cmd cmd, *args, &block
    command cmd, *args, &block
  end
end

class OutboundListenerWithAppsAndApi < Librevox::Listener::Outbound
  def session_initiated
    sample_app "foo" do
      api.sample_cmd "bar" do
        sample_app "baz"
      end
    end
  end
end

describe "Outbound listener with both apps and api calls" do
  extend Librevox::Test::Matchers

  before do
    @listener = OutboundListenerWithAppsAndApi.new(nil)

    command_reply "Session-Var" => "First",
                  "Unique-ID"   => "1234"
    event_and_linger_replies
    3.times {@listener.outgoing_data.shift}
  end

  should "wait for response before calling next app/cmd" do
    @listener.should send_application "foo"
    command_reply :body => "+OK"
    @listener.should update_session
    channel_data

    @listener.should send_command "api bar"
    api_response :body => "+OK"

    @listener.should send_application "baz"
  end
end

class OutboundListenerWithUpdateSessionCallback < Librevox::Listener::Outbound
  def session_initiated
    update_session do
      application "send", "yay, #{session[:session_var]}"
    end
  end
end

describe "Outbound listener with update session callback" do
  extend Librevox::Test::Matchers

  before do
    @listener = OutboundListenerWithUpdateSessionCallback.new(nil)
    command_reply "Session-Var" => "First",
                  "Unique-ID"   => "1234"
    event_and_linger_replies
    3.times {@listener.outgoing_data.shift}

    @listener.should update_session
    api_response :body => {
      "Event-Name"  => "CHANNEL_DATA",
      "Session-Var" => "Second"
    }
  end

  should "execute callback" do
    @listener.outgoing_data.shift.should =~ /yay,/
  end

  should "update session before calling callback" do
    @listener.should send_application "send", "yay, Second"
  end
end
