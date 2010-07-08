require './spec/helper'
require 'librevox/commands'

module CommandTest
  include Librevox::Commands

  extend self

  def command name, args=""
    {
      :name   => name,
      :args   => args
    }
  end
end

C = CommandTest

describe Librevox::Commands do
  should "status" do
    cmd = C.status
    cmd[:name].should == "status"
  end

  describe "originate" do
    should "originate url to extension" do
      cmd = C.originate "user/coltrane", :extension => 4000
      cmd[:name].should == "originate"
      cmd[:args].should == "{}user/coltrane 4000"
    end

    should "send variables" do
      cmd = C.originate 'user/coltrane',
                        :extension => 1234,
                        :ignore_early_media => true,
                        :other_option => "value"

      cmd[:args].should.match %r|^\{\S+\}user/coltrane 1234$|
      cmd[:args].should.match /ignore_early_media=true/
      cmd[:args].should.match /other_option=value/
    end

    should "take dialplan and context" do
      cmd = C.originate "user/coltrane",
                        :extension => "4000",
                        :dialplan => "XML",
                        :context => "public"
      cmd[:name].should == "originate"
      cmd[:args].should == "{}user/coltrane 4000 XML public"
    end
  end

  should "fsctl" do
    cmd = C.fsctl :hupall, :normal_clearing
    cmd[:name].should == "fsctl"
    cmd[:args].should == "hupall normal_clearing"
  end

  should "huball" do
    cmd = C.hupall
    cmd[:name].should == "hupall"

    cmd = C.hupall("some_cause")
    cmd[:name].should == "hupall"
    cmd[:args].should == "some_cause"
  end

  describe "hash" do
    should "insert" do
      cmd = C.hash :insert, :firmafon, :foo, "some value or other"
      cmd[:name].should == "hash"
      cmd[:args].should == "insert/firmafon/foo/some value or other"
    end

    should "select" do
      cmd = C.hash :select, :firmafon, :foo
      cmd[:name].should == "hash"
      cmd[:args].should == "select/firmafon/foo"
    end

    should "delete" do
      cmd = C.hash :delete, :firmafon, :foo
      cmd[:name].should == "hash"
      cmd[:args].should == "delete/firmafon/foo"
    end
  end

  describe "uuid_park" do
    should "park" do
      cmd = C.uuid_park "1234-abcd"
      cmd[:name].should == "uuid_park"
      cmd[:args].should == "1234-abcd"
    end
  end

  describe "uuid_bridge" do
    should "bridge" do
      cmd = C.uuid_bridge "1234-abcd", "9090-ffff"
      cmd[:name].should == "uuid_bridge"
      cmd[:args].should == "1234-abcd 9090-ffff"
    end
  end
end
