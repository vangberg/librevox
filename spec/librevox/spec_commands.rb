require 'spec/helper'
require 'librevox/commands'

module CommandTest
  include Librevox::Commands

  extend self

  def execute_cmd(name, args="", &block)
    {
      :name   => name,
      :args   => args,
      :block  => block
    }
  end
end

describe Librevox::Commands do
  C = CommandTest

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
end
