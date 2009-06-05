require "lib/fsr"
require FSR::ROOT/".."/:spec/:helper
require FSR::ROOT/:fsr/:listener/:outbound

# Bare class to use for testing
class MyListener < FSR::Listener::Outbound
attr_reader :exten
  def session_initiated
    @exten = @session.headers[:caller_caller_id_number]
  end

  def send_data data
    sent_data << data
  end

  def sent_data
    @sent_data ||= ''
  end

end

# helper to instantiate a new MyListener
def my_listener
  MyListener.new
end
gem "tmm1-em-spec"
require "em/spec"
describe "FSR::Listener::Outbound class" do

  it "defines #post_init" do
    FSR::Listener::Outbound.method_defined?(:post_init).should == true
  end

end

EM.describe FSR::Listener::Outbound do
  should "be true" do
    done
  end

  
end

EM.describe MyListener do
  before do
    @listener = MyListener.new(nil)
  end

  should "be able to sendmsg to FreeSWITCH" do
    @listener.sendmsg("foo")
    @listener.sent_data.should.equal "connect\n\nsendmsg\nfoo\n"
    done
  end

  should "be able to receive new session and have an exten" do
    @listener.receive_data("Content-Length: 0\nCaller-Caller-ID-Number: 8176907937\n\n")
    @listener.exten.should.equal "8176907937"
    done
  end
end

