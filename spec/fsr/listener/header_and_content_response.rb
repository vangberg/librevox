require 'spec/helper'
require 'fsr/listener/header_and_content_response'

describe FSL::HeaderAndContentResponse do
  HCR = FSL::HeaderAndContentResponse

  it "is initializable without arguments" do
    hcr = HCR.new
    hcr.headers.should.be.empty
    hcr.content.should.be.empty
  end

  it "can be created with headers" do
    hcr = HCR.new(:headers => {:a => 'b', :c => 'd'})
    hcr.headers.should == {:a => 'b', :c => 'd'}
  end

  it 'strips whitespace around header values' do
    hcr = HCR.new(:headers => {:a => ' b', :c => "d\t\n"})
    hcr.headers.should == {:a => 'b', :c => 'd'}
  end

  it "returns an empty string if there's no event-name" do
    hcr = HCR.from_raw([""], [""])
    hcr.class.should == HCR
    hcr.event_name.should == ''
  end

  it "returns the event-name if there is one" do
    hcr = HCR.from_raw([""], ["event-name: foo"])
    hcr.event_name.should == 'foo'
    hcr.class.should == HCR::ParsedContent
  end

  it "can check for an event name in content" do
    hcr = HCR.new(:content => {:event_name => ' YAY', :stuff => "d"})
    hcr.class.should == HCR

    hcr.has_event_name?('YAY').should.not == nil
    hcr.content[:event_name] = 'NOES'
    hcr.has_event_name?('YAY').should == false
  end
end
