require 'spec/helper'
require 'librevox/applications'

module ApplicationTest
  include Librevox::Applications

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

describe Librevox::Applications do
  A = ApplicationTest

  should "answer" do
    app = A.answer
    app[:name].should == "answer"
  end

  describe "bind_meta_app" do
    should "bind meta app" do
      app = A.bind_meta_app :key => "2",
                            :listen_to => :a,
                            :respond_on => :s,
                            :application => "hangup"

      app[:name].should == "bind_meta_app"
      app[:args].should == "2 a s hangup"
    end

    should "bind meta app with parameters" do
      app = A.bind_meta_app :key => "2",
                            :listen_to => :a,
                            :respond_on => :s,
                            :application => "execute_extension",
                            :parameters => "dx XML features"

      app[:name].should == "bind_meta_app"
      app[:args].should == "2 a s execute_extension::dx XML features"
    end
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

  should "playback" do
    app = A.playback("uri://some/file.wav")
    app[:name].should == "playback"
    app[:args].should == "uri://some/file.wav"
  end

  describe "read" do
    should "read with defaults" do
      app = A.read "please-enter.wav"
      app[:name].should == "read"
      app[:args].should == "1 2 please-enter.wav read_digits_var 5000 #"
      app[:params][:read_var].should == "read_digits_var"
    end

    should "take params" do
      app = A.read "please-enter.wav",
        :min          => 2,
        :max          => 3,
        :terminators  => "0",
        :timeout      => 10000,
        :read_var     => "other_var"

      app[:args].should == "2 3 please-enter.wav other_var 10000 0"
      app[:params][:read_var].should == "other_var"
    end
  end

  describe "record" do
    should "start recording" do
      app = A.record "/path/to/file.mp3"
      app[:name].should == "record"
      app[:args].should == "/path/to/file.mp3"
    end

    should "start recording with time limit" do
      app = A.record "/path/to/file.mp3", :limit => 15
      app[:name].should == "record"
      app[:args].should == "/path/to/file.mp3 15"
    end
  end

  should "set" do
    app = A.set("foo", "bar")
    app[:name].should == "set"
    app[:args].should == "foo=bar"
  end

  should "transfer" do
    app = A.transfer "new_extension"
    app[:name].should == "transfer"
    app[:args].should == "new_extension"
  end
end
