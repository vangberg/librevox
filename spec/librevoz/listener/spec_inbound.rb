require 'spec/helper'
require 'spec/librevoz/listener'

require 'librevoz/listener/inbound'

class InboundTestListener < Librevoz::Listener::Inbound
end

describe "Inbound listener" do
  before do
    @listener = InboundTestListener.new(nil)
  end

  behaves_like "events"
  behaves_like "api commands"

  should "authorize and subscribe to events" do
    @listener.outgoing_data.shift.should == "auth ClueCon\n\n"
    @listener.outgoing_data.shift.should == "event plain ALL\n\n"
  end
end
