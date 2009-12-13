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
      cmd = C.originate("user/coltrane", "4000")
      cmd[:name].should == "originate"
      cmd[:args].should == "{}user/coltrane 4000"
    end

    should "send variables" do
      cmd = C.originate 'user/coltrane', 1234,
                        :ignore_early_media => true,
                        :other_option => "value"

      cmd[:args].should.match %r|^\{\S+\}user/coltrane 1234$|
      cmd[:args].should.match /ignore_early_media=true/
      cmd[:args].should.match /other_option=value/
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
end
