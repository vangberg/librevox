require 'spec/helper'
require 'fsr/cmd'

header = <<EOF
Content-Type: api/response
Content-Length: 152
EOF
content = <<EOF
"UP 0 years, 0 days, 0 hours, 27 minutes, 9 seconds, 537 milliseconds, 793 microseconds
0 session(s) since startup
0 session(s) 0/30
1000 session(s) max
EOF

RESPONSE = FSR::Response.new(header, content)

describe FSR::Cmd::Status do
  before do
    @cmd = FSR::Cmd::Status.new
  end

  should "request status" do
    @cmd.raw.should == "api status"
  end

  describe "response" do
    before do
      @cmd.response = RESPONSE
      @response = @cmd.response
    end

    should "return status response" do
      @response.class.should == FSR::Cmd::Status::Response
    end

    should "have uptime in seconds" do
      @response.uptime.should == (27 * 60) + 9
    end

    should "parse sessions" do
      @response.sessions.should == [0, 30]
    end
  end
end
