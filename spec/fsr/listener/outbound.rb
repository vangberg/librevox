require "lib/fsr"
require FSR::ROOT/".."/:spec/:helper
require FSR::ROOT/:fsr/:listener/:outbound
gem "tmm1-em-spec"
require "em/spec"

# Bare class to use for testing
class MyListener < FSR::Listener::Outbound
  attr_accessor :recvd_reply, :state_machine_test

  def session_initiated
  end

  def send_data(data)
    sent_data << data
  end

  def sent_data
    @sent_data ||= ''
  end

  def receive_reply(reply)
    recvd_reply << reply
  end

  def recvd_reply
    @recvd_reply ||= []
  end

  def do_something(&block)
    @queue << block if block_given? 
  end

  def test_state_machine
    @state_machine_test = nil
    do_something do 
      @state_machine_test = "one"

      do_something do
        @state_machine_test = "two"

        do_something do
          @state_machine_test = "three"
        end
      end
    end
  end

end

# Begin testing MyListener
EM.describe MyListener do

  before do
    @listener = MyListener.new(nil)
  end

  should "send connect to freeswitch upon a new connection" do
    @listener.receive_data("Content-Length: 0\nCaller-Caller-ID-Number: 8675309\n\n")
    @listener.sent_data.should.equal "connect\n\n"
    done
  end

  should "be able to receive a connection and establish a session " do
    @listener.receive_data("Content-Length: 0\nTest: Testing\n\n")
    @listener.session.class.should.equal FSR::Listener::HeaderAndContentResponse
    done
  end

  should "be able to read FreeSWITCH channel variables through session" do
    @listener.receive_data("Content-Length: 0\nCaller-Caller-ID-Number: 8675309\n\n")
    @listener.session.headers[:caller_caller_id_number].should.equal "8675309"
    done
  end

  should "be able to receive and process a response if not sent in one transmission" do
    @listener.receive_data("Content-Length: ")
    @listener.receive_data("0\nCaller-Caller-")
    @listener.receive_data("ID-Number: 8675309\n\n")
    @listener.session.headers[:caller_caller_id_number].should.equal "8675309"
    done
  end

  should "be able to dispatch our receive_reply callback method after a session is already established" do
    # This should establish the session
    @listener.receive_data("Content-Length: 0\nTest-Data: foo\n\n")

    # This should be a response, not a session
    @listener.receive_data("Content-Length: 0\nTest-Reply: bar\n\n")

    @listener.session.headers[:test_data].should.equal 'foo'
    @listener.recvd_reply.first.headers[:test_reply].should.equal 'bar'
    done
  end

  should "use procs to 'fake' I/O blocking and wait for a response before calling the next proc" do
    @listener.receive_data("Content-Length: 0\nEstablished-Session: session\n\n")
    @listener.test_state_machine
    @listener.state_machine_test.should.equal nil
    @listener.receive_data("Content-Length: 3\n\nOk\n\n")
    @listener.state_machine_test.should.equal "one"
    @listener.receive_data("Content-Length: 3\n\nOk\n\n")
    @listener.state_machine_test.should.equal "two"
    @listener.receive_data("Content-Length: 3\n\nOk\n\n")
    @listener.state_machine_test.should.equal "three"
    done
  end

end
