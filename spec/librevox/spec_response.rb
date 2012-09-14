require './spec/helper'
require 'librevox/response'

include Librevox

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

  should "allow setting content from a hash" do
    response = Response.new
    response.content = {:key => 'value'}
    response.content.should.equal({:key => 'value'})
  end

  should "check for event" do
    response = Response.new("Content-Type: command/reply", "Event-Name: Hangup")
    response.event?.should.be.true
    response.event.should == "Hangup"

    response = Response.new("Content-Type: command/reply", "Foo-Bar: Baz")
    response.event?.should.be.false
  end

  should "check for api response" do
    response = Response.new("Content-Type: api/response", "+OK")
    response.api_response?.should.be.true

    response = Response.new("Content-Type: command/reply", "Foo-Bar: Baz")
    response.api_response?.should.be.false
  end

  should "check for command reply" do
    response = Response.new("Content-Type: command/reply", "+OK")
    response.command_reply?.should.be.true

    response = Response.new("Content-Type: api/response", "Foo-Bar: Baz")
    response.command_reply?.should.be.false
  end

  should "parse body from command reply" do
    response = Response.new("Content-Type: command/reply", "Foo-Bar: Baz\n\nMessage body")
    response.content[:body].should.equal "Message body"
  end
end
