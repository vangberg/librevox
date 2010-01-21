require 'spec/helper'
require 'librevox/applications'

module AppTest
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
  describe "answer" do
    should "answer" do
      app = AppTest.answer
      app[:name].should == "answer"
    end
  end

  describe "att_xfer" do
    should "transfer to endpoint" do
      app = AppTest.att_xfer("user/davis")
      app[:name].should == "att_xfer"
      app[:args].should == "user/davis"
    end
  end

  describe "bind_meta_app" do
    should "bind meta app" do
      app = AppTest.bind_meta_app :key => "2",
                            :listen_to => :a,
                            :respond_on => :s,
                            :application => "hangup"

      app[:name].should == "bind_meta_app"
      app[:args].should == "2 a s hangup"
    end

    should "bind meta app with parameters" do
      app = AppTest.bind_meta_app :key => "2",
                            :listen_to => :a,
                            :respond_on => :s,
                            :application => "execute_extension",
                            :parameters => "dx XML features"

      app[:name].should == "bind_meta_app"
      app[:args].should == "2 a s execute_extension::dx XML features"
    end
  end

  describe "bridge" do
    should "bridge to endpoints" do
      app = AppTest.bridge('user/coltrane')
      app[:name].should == "bridge"
      app[:args].should == 'user/coltrane'

      app = AppTest.bridge('user/coltrane', 'user/davis')
      app[:args].should == 'user/coltrane,user/davis'
    end

    should "bridge with variables" do
      app = AppTest.bridge('user/coltrane', 'user/davis', :foo => 'bar', :lol => 'cat')
      app[:name].should == "bridge"

      # fragile. hashes are not ordered in ruby 1.8
      app[:args].should == "{foo=bar,lol=cat}user/coltrane,user/davis"
    end

    should "bridge with failover" do
      app = AppTest.bridge(
        ['user/coltrane', 'user/davis'], ['user/sun-ra', 'user/taylor']
      )

      app[:name].should == "bridge"
      app[:args].should == "user/coltrane,user/davis|user/sun-ra,user/taylor"
    end

    # should "bridge with per endpoint variables" do
    # end
  end

  describe "deflect" do
    should "deflect call" do
      app = AppTest.deflect "sip:miles@davis.org"
      app[:name].should == "deflect"
      app[:args].should == "sip:miles@davis.org"
    end
  end

  describe "export" do
    should "export variable" do
      app = AppTest.export 'some_var'
      app[:name].should == "export"
      app[:args].should == "some_var"
    end

    should "only export to b-leg " do
      app = AppTest.export 'some_var', :local => false
      app[:name].should == "export"
      app[:args].should == "nolocal:some_var"
    end
  end

  describe "gentones" do
    should "generate tones" do
      app = AppTest.gentones("%(500,0,800)")
      app[:name].should == "gentones"
      app[:args].should == "%(500,0,800)"
    end
  end

  should "hangup" do
    app = AppTest.hangup
    app[:name].should == "hangup"

    app = AppTest.hangup("some cause")
    app[:args].should == "some cause"
  end

  describe "play_and_get_digits" do
    should "have defaults" do
      app = AppTest.play_and_get_digits "please-enter", "wrong-try-again"
      app[:name].should == "play_and_get_digits"
      app[:args].should == "1 2 3 5000 # please-enter wrong-try-again read_digits_var \\d+"
      app[:params][:read_var].should == "read_digits_var"
    end

    should "take params" do
      app = AppTest.play_and_get_digits "please-enter", "invalid-choice",
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
    app = AppTest.playback("uri://some/file.wav")
    app[:name].should == "playback"
    app[:args].should == "uri://some/file.wav"
  end

  describe "pre_answer" do
    should "pre_answer" do
      app = AppTest.pre_answer
      app[:name].should == "pre_answer"
    end
  end

  describe "read" do
    should "read with defaults" do
      app = AppTest.read "please-enter.wav"
      app[:name].should == "read"
      app[:args].should == "1 2 please-enter.wav read_digits_var 5000 #"
      app[:params][:read_var].should == "read_digits_var"
    end

    should "take params" do
      app = AppTest.read "please-enter.wav",
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
      app = AppTest.record "/path/to/file.mp3"
      app[:name].should == "record"
      app[:args].should == "/path/to/file.mp3"
    end

    should "start recording with time limit" do
      app = AppTest.record "/path/to/file.mp3", :limit => 15
      app[:name].should == "record"
      app[:args].should == "/path/to/file.mp3 15"
    end
  end

  describe "redirect" do
    should "redirect to URI" do
      app = AppTest.redirect("sip:miles@davis.org")
      app[:name].should == "redirect"
      app[:args].should == "sip:miles@davis.org"
    end
  end

  should "set" do
    app = AppTest.set("foo", "bar")
    app[:name].should == "set"
    app[:args].should == "foo=bar"
  end

  should "transfer" do
    app = AppTest.transfer "new_extension"
    app[:name].should == "transfer"
    app[:args].should == "new_extension"
  end

  describe "unbind_meta_app" do
    should "unbind" do
      app = AppTest.unbind_meta_app 3
      app[:name].should == "unbind_meta_app"
      app[:args].should == "3"
    end
  end

  describe "unset" do
    should "unset a variable" do
      app = AppTest.unset('foo')
      app[:name].should == "unset"
      app[:args].should == "foo"
    end
  end
end
