require 'spec/helper'
require 'fsr/cmd'

header = <<EOF
Content-Type: api/response
Content-Length: 151
EOF
content = <<EOF
"UP 1 years, 2 days, 3 hours, 4 minutes, 5 seconds, 537 milliseconds, 793 microseconds
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
      minute = 60
      hour = 60 * minute
      day = 24 * hour
      year = 365 * day
      @response.uptime.should == year + 2 * day + 3 * hour + 4 * minute + 5
    end

    should "parse sessions" do
      @response.sessions.should == [0, 30]
    end
  end
end
