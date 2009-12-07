require 'spec/helper'
require 'fsr/listener'

include FSR::Listener

describe Response do
  should "parse headers to hash" do
    response = Response.new("Header1:some value\nOther-Header:other value")

    response.headers.should.include :header1
    response.headers[:header1].should.equal "some value"

    response.headers.should.include :other_header
    response.headers[:other_header].should.equal "other value"
  end

  should "parse key-value content to hash" do
    response = Response.new("", "Key:value\nOther-Key:other value")

    response.content.class.should.equal Hash
    response.content[:key].should.equal "value"
    response.content[:other_key].should.equal "other value"
  end

  should "not parse regular content" do
    response = Response.new("", "OK.")

    response.content.class.should.equal String
    response.content.should.equal "OK."
  end

  should "check for event" do
    response = Response.new("", "Event-Name: Hangup")
    response.event?.should.be.true
    response.event.should == "Hangup"

    response = Response.new("", "Foo-Bar: Baz")
    response.event?.should.be.false
  end
end
