require './spec/helper'
require './spec/librevox/listener'

require 'librevox/listener/inbound'

class InboundTestListener < Librevox::Listener::Inbound
end

class InboundFilterTestListener < Librevox::Listener::Inbound
  events ['CUSTOM', 'CHANNEL_EXECUTE']

  filters 'Caller-Context' => ['default', 'example'], 'Caller-Privacy-Hide-Name' => 'no'
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
    @listener.outgoing_data.shift.should == nil
  end
end

describe "Inbound listener with filtering" do
  before do
    @listener = InboundFilterTestListener.new(nil)
  end

  behaves_like "events"
  behaves_like "api commands"

  should "authorize and subscribe to events" do
    @listener.connection_completed
    @listener.outgoing_data.shift.should == "auth ClueCon\n\n"
    @listener.outgoing_data.shift.should == "event plain CUSTOM CHANNEL_EXECUTE\n\n"
    @listener.outgoing_data.shift.should == "filter Caller-Context default\n\n"
    @listener.outgoing_data.shift.should == "filter Caller-Context example\n\n"
    @listener.outgoing_data.shift.should == "filter Caller-Privacy-Hide-Name no\n\n"
    @listener.outgoing_data.shift.should == nil
  end
end
