require 'spec/helper'
require 'spec/fsr/listener'
require 'fsr/listener/outbound'

class SampleApp < FSR::App::Application
  attr_reader :arguments

  def initialize(*args)
    @arguments = args
  end

  def app_name
    "sample_app"
  end
end

class OutboundTestListener < Listener::Outbound
  def session_initiated
    send_data "session was initiated"
  end
end

describe "Outbound listener" do
  before do
    @listener = OutboundTestListener.new(nil)
  end

  should "connect to freeswitch and subscribe to events" do
    @listener.outgoing_data.shift.should.equal "connect\n\n"
    @listener.outgoing_data.shift.should.equal "myevents\n\n"
    @listener.outgoing_data.shift.should.equal "linger\n\n"
  end

  should "establish a session" do
    @listener.receive_data("Content-Length: 0\nTest: Testing\n\n")
    @listener.session.class.should.equal FSR::Listener::Response
  end

  should "call #session_initated after establishing new session" do
    @listener.receive_data("Content-Length: 0\nTest: Testing\n\n")

    @listener.read_data.should.equal "session was initiated"
  end

  should "make channel variables available through session" do
    @listener.receive_data("Content-Length: 0\nCaller-Caller-ID-Number: 8675309\n\n")
    @listener.session.headers[:caller_caller_id_number].should.equal "8675309"
  end

  should "receive and process a response split in multiple transactions" do
    @listener.receive_data("Content-Length: ")
    @listener.receive_data("0\nCaller-Caller-")
    @listener.receive_data("ID-Number: 8675309\n\n")
    @listener.session.headers[:caller_caller_id_number].should.equal "8675309"
  end

  behaves_like "events"

  should "register app" do
    @listener.respond_to?(:sample_app).should.be.false?

    FSR::Listener::Outbound.register_app(SampleApp)

    @listener.respond_to?(:sample_app).should.be.true?
  end
end

class OutboundListenerWithNestedApps < Listener::Outbound
  register_app SampleApp

  def session_initiated
    sample_app "foo" do
      sample_app "bar"
    end
  end
end

describe "Outbound listener with apps using fake blocks " do
  before do
    @listener = OutboundListenerWithNestedApps.new(nil)

    # Establish session and get rid of connect-string
    @listener.receive_data("Content-Length: 0\nEstablish-Session: OK\n\n")
    3.times {@listener.outgoing_data.shift}
  end

  should "only send one app at a time" do
    @listener.read_data.should == SampleApp.new("foo").sendmsg
    @listener.read_data.should == nil

    @listener.receive_data("Content-Length: 0\n\n")
    @listener.read_data.should == SampleApp.new("bar").sendmsg
    @listener.read_data.should == nil
  end
end

class ReaderApp < FSR::App::Application
  def read_channel_var
    "a_reader_var"
  end

  def app_name
    "reader_app"
  end
end

class OutboundListenerWithReader < Listener::Outbound
  register_app ReaderApp
  
  def session_initiated
    reader_app do |data|
      send_data "read this: #{data}"
    end
  end
end

describe "Outbound listener with app reading data" do
  before do
    @listener = OutboundListenerWithReader.new(nil)

    # Establish session and get rid of connect-string
    @listener.receive_data("Content-Length: 0\nSession-Var: First\nUnique-ID: 1234\n\n")
    3.times {@listener.outgoing_data.shift}
  end

  should "send uuid_dump to get channel var" do
    @listener.read_data.should == "api uuid_dump 1234\n\n"
  end

  should "update session with new data" do
    @listener.receive_data("Content-Length: 44\n\nEvent-Name: CHANNEL_DATA\nSession-Var: Second\n\n")
    @listener.session.content[:session_var].should == "Second"
  end

  should "pass value of channel variable to block" do
    @listener.receive_data("Content-Length: 3\n\n+OK\n\n")
    @listener.receive_data("Content-Length: 50\n\nEvent-Name: CHANNEL_DATA\na-reader-var: some value\n\n")
    @listener.read_data.should == "read this: some value"
  end
end

class OutboundListenerWithNonNestedApps < Listener::Outbound
  attr_reader :queue

  register_app SampleApp
  register_app ReaderApp

  def session_initiated
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
    @listener.receive_data("Content-Length: 0\nSession-Var: First\nUnique-ID: 1234\n\n")
    3.times {@listener.outgoing_data.shift}
  end

  should "wait for response before calling next proc" do
    # response to sample_app
    @listener.read_data.should.not == "read this: some value"
    @listener.receive_data("Content-Length: 3\n\n+OK\n\n")

    # response to reader_app
    @listener.read_data.should.not == "read this: some value"
    @listener.receive_data("Content-Length: 3\n\n+OK\n\n")

    # response to uuid_dump caused by reader_app
    @listener.read_data.should.not == "read this: some value"
    @listener.receive_data("Content-Length: 50\n\nEvent-Name: CHANNEL_DATA\na-reader-var: some value\n\n")

    @listener.read_data.should == "the end: some value"
  end
end
