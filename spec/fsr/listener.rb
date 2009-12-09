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

# Stupid hack. How do we make bacon ignore this file?
describe "Listener" do
  should "have empty spec" do
    true.should.be.true?
  end
end
