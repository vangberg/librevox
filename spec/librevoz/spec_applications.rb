require 'spec/helper'
require 'librevoz/applications'

module ApplicationTest
  include Librevoz::Applications

  extend self

  def execute_app(name, args=[], params={}, &block)
    {
      :name   => name,
      :args   => args,
      :params => params,
      :block  => block
    }
  end
end

describe Librevoz::Applications do
  A = ApplicationTest

  should "answer" do
    app = A.answer
    app[:name].should == "answer"
  end

  should "bridge" do
    app = A.bridge('user/coltrane')
    app[:name].should == "bridge"
    app[:args].should == 'user/coltrane'

    app = A.bridge('user/coltrane', 'user/davis')
    app[:args].should == 'user/coltrane,user/davis'
  end

  should "hangup" do
    app = A.hangup
    app[:name].should == "hangup"

    app = A.hangup("some cause")
    app[:args].should == "some cause"
  end

  describe "play_and_get_digits" do
    should "have defaults" do
      app = A.play_and_get_digits "please-enter", "wrong-try-again"
      app[:name].should == "play_and_get_digits"
      app[:args].should == "1 2 3 5000 # please-enter wrong-try-again read_digits_var \\d+"
      app[:params][:read_var].should == "read_digits_var"
    end

    should "take params" do
      app = A.play_and_get_digits "please-enter", "invalid-choice",
        :min          => 2,
        :max          => 3,
        :tries        => 4,
        :terminators  => "0",
        :timeout      => 10000,
        :read_var     => "other_var",
        :regexp       => "[125]"

      app[:args].should == "2 3 4 10000 0 please-enter invalid-choice other_var [125]"
      app[:params][:read_var].should == "other_var"
    end
  end
end
