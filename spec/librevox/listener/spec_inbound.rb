require './spec/helper'
require './spec/librevox/listener'

require 'librevox/listener/inbound'

class InboundTestListener < Librevox::Listener::Inbound
end

describe "Inbound listener" do
  before do
    @listener = InboundTestListener.new(nil)
  end

  behaves_like "events"
  behaves_like "api commands"

  should "authorize and subscribe to events" do
    @listener.connection_completed
    @listener.outgoing_data.shift.should == "auth ClueCon\n\n"
    @listener.outgoing_data.shift.should == "event plain ALL\n\n"
  end
end
