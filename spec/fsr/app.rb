require 'spec/helper'
require 'fsr/app'

describe "Basic FSR::App module" do
  it "Aliases itself as FSA" do
    require "fsr/app"
    FSA.should == FSR::App 
  end
end

describe "Boilerplate Application" do
  before do
    @app = FSR::App::Application.new
  end

  should "call default command" do
    @app.sendmsg.should == "call-command: execute\nexecute-app-name: application\n\n"
  end

  should "use #app_name as application name" do
    def @app.app_name; "foo_bar" end

    @app.sendmsg.should == "call-command: execute\nexecute-app-name: foo_bar\n\n"
  end

  should "send arguments" do
    def @app.arguments; ["foo", "bar"] end

    @app.sendmsg.should == "call-command: execute\nexecute-app-name: application\nexecute-app-arg: foo bar\n\n"
  end

  should "send event-lock if #event_lock is true" do
    def @app.event_lock; true end

    @app.sendmsg.should == "call-command: execute\nexecute-app-name: application\nevent-lock: true\n\n"
  end
end

require 'fsr/listener'
require 'spec/mock_listener'

class FooApp < FSR::App::Application
end

describe "register" do
  before do
    @listener = FSR::Listener::Outbound.new(nil)
  end

  should "add app to outbound listener" do
    @listener.should.not.respond_to? :fooapp

    FSR::App.register FooApp

    @listener.should.respond_to? :fooapp
  end
end
