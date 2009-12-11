require 'spec/helper'
require 'fsr/cmd'

describe FSR::Cmd::DomainExists do
  before do
    @cmd = FSR::Cmd::DomainExists.new("domain")
  end

  should "check if domain exists" do
    @cmd.raw.should == "api domain_exists domain"
  end

  should "parse true/false return value" do
    @cmd.response = FSR::Response.new("", "true")
    @cmd.response.should.be.true

    @cmd.response = FSR::Response.new("", "false")
    @cmd.response.should.be.false
  end
end
