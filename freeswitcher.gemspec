# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{freeswitcher}
  s.version = "0.5.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jayson Vaughn", "Michael Fellinger", "Kevin Berry", "TJ Vanderpoel"]
  s.date = %q{2009-12-10}
  s.description = %q{# Freeswitcher  > An EventMachine-based Ruby library for interacting with the open source  > telephony platform [FreeSWITCH](http://www.freeswitch.org).  ## Prerequisites  Freeswitcher lets you interact with FreeSWITCH through mod_event_socket. You should know how the event socket works, and the differences between inbound and outbound event sockets before proceeding. The [wiki page on mod_event_socket](http://wiki.freeswitch.org/wiki/Event_Socket) is a good place to start.  ## Inbound listener  To create an inbound listener, you should subclass `FSR::Listener::Inbound` and add custom behaviour to it. An inbound listener subscribes to all events from FreeSWITCH, and lets you react on events in two different ways:  1.      By overiding `on_event` which gets called every time an event arrives.  2.      By adding an event hook with `add_event_hook`, which will get called every time an event with the specified name arrives.  The header and content of the event is accessible through `event`.  Below is an example of an inbound listener utilising all the aforementioned techniques:  require 'fsr' require 'fsr/listener/inbound'  class MyInbound < FSR::Listener::Inbound def on_event # Be sure to check out the content of `event`. It has all the good stuff. FSR::Log.info "Got event: #{event.content[:event_name]}" end  # You can add a hook for a certain event: add_event_hook :CHANNEL_HANGUP do FSR::Log.info "Channel hangup!"  # It is instance_eval'ed, so you can use your instance methods etc: do_something end  def do_something ... end end  ## Outbound listener  You create an outbound listener by subclassing `FSR::Listener::Outbound`.   ### Events  An outbound listener has the same event functionality as the inbound listener, but it only recieves events related to that given session.  ### Dialplan  When a call is made and Freeswitch connects to the outbound event listener, `session_initiated` is called. This is where you set up your dialplan:  def session_initiated answer set "some_var", "some value" playback "path/to/file" hangup end  When using applications that expects a reply, such as `play_and_get_digits`, you have to use callbacks to read the value, as the function itself returns immediately due to the async nature of EventMachine:  def session_initiated answer  play_and_get_digits "enter-number.wav", "error.wav" do |digit| FSR::Log.info "User pressed #{digit}" playback "thanks-for-the-input.wav" hangup end end  ### Available applications  ## Starting listeners  To start a single listener, connection/listening on localhost on the default port is quite simple:  FSR.start SomeListener  it takes an optional hash with arguments:  FSR.start SomeListener, :host => "1.2.3.4", :port => "8087", :auth => "pwd"  Multiple listeners can be started at once by passing a block to `FSR.start`:  FSR.start do run SomeListener run OtherListener, :port => "8080" end  ## Originating a new call with `FSR::CommandSocket`  >> require ‘fsr’ => true  >> FSR.load_all_commands => [:sofia, :originate]  >> sock = FSR::CommandSocket.new => #<FSR::CommandSocket:0xb7a89104 @server=“127.0.0.1”, @socket=#<TCPSocket:0xb7a8908c>, @port=“8021”, @auth=“ClueCon”>  >> sock.originate(:target => ‘sofia/gateway/carlos/8179395222’, :endpoint => FSR::App::Bridge.new(“user/bougyman”)).run => {“Job-UUID”=>“732075a4-7dd5-4258-b124-6284a82a5ae7”, “body”=>“”, “Content-Type”=>“command/reply”,  “Reply-Text”=>“+OK Job-UUID: 732075a4-7dd5-4258-b124-6284a82a5ae7”}   ## Writing applications  ## Extras  * Website: [http://code.rubyists.com/projects/fs](http://code.rubyists.com/projects/fs) * Source: [http://gitorious.org/fsr](http://gitorious.org/fsr) * Wiki: [http://gitorious.org/fsr/pages/Home](http://gitorious.org/fsr/pages/Home) * IRC: #rubyists @ freenode  ## License  (c) 2009 The Rubyists (Jayson Vaughn, Tj Vanderpoel, Michael Fellinger, Kevin Berry)   Distributed under the terms of the MIT license.}
  s.email = %q{FreeSWITCHeR@rubyists.com}
  s.files = [".gitignore", "AUTHORS", "CHANGELOG", "CHANGES", "License.txt", "MANIFEST", "NEWS", "README.md", "Rakefile", "examples/inbound_listener.rb", "examples/multiple_listeners.rb", "examples/outbound_listener.rb", "freeswitcher.gemspec", "lib/fsr.rb", "lib/fsr/app.rb", "lib/fsr/app/answer.rb", "lib/fsr/app/bind_meta_app.rb", "lib/fsr/app/bridge.rb", "lib/fsr/app/conference.rb", "lib/fsr/app/execute_app.rb", "lib/fsr/app/fifo.rb", "lib/fsr/app/fs_break.rb", "lib/fsr/app/fs_sleep.rb", "lib/fsr/app/hangup.rb", "lib/fsr/app/limit.rb", "lib/fsr/app/log.rb", "lib/fsr/app/play_and_get_digits.rb", "lib/fsr/app/playback.rb", "lib/fsr/app/read.rb", "lib/fsr/app/set.rb", "lib/fsr/app/speak.rb", "lib/fsr/app/transfer.rb", "lib/fsr/app/uuid_dump.rb", "lib/fsr/app/uuid_getvar.rb", "lib/fsr/app/uuid_setvar.rb", "lib/fsr/cmd.rb", "lib/fsr/cmd/calls.rb", "lib/fsr/cmd/fsctl.rb", "lib/fsr/cmd/originate.rb", "lib/fsr/cmd/sofia.rb", "lib/fsr/cmd/sofia/profile.rb", "lib/fsr/cmd/sofia/status.rb", "lib/fsr/cmd/sofia_contact.rb", "lib/fsr/cmd/status.rb", "lib/fsr/cmd/uuid_dump.rb", "lib/fsr/command_socket.rb", "lib/fsr/database.rb", "lib/fsr/database/call_limit.rb", "lib/fsr/database/core.rb", "lib/fsr/database/sofia_reg_external.rb", "lib/fsr/database/sofia_reg_internal.rb", "lib/fsr/database/voicemail_default.rb", "lib/fsr/listener.rb", "lib/fsr/listener/base.rb", "lib/fsr/listener/inbound.rb", "lib/fsr/listener/outbound.rb", "lib/fsr/listener/response.rb", "lib/fsr/model/call.rb", "lib/fsr/version.rb", "tasks/authors.rake", "tasks/bacon.rake", "tasks/changelog.rake", "tasks/copyright.rake", "tasks/gem.rake", "tasks/gem_installer.rake", "tasks/install_dependencies.rake", "tasks/manifest.rake", "tasks/release.rake", "tasks/reversion.rake", "tasks/setup.rake", "tasks/spec.rake", "tasks/yard.rake", "spec/helper.rb", "spec/fsr_listener_helper.rb", "spec/fsr/app.rb", "spec/fsr/app/answer.rb", "spec/fsr/app/bind_meta_app.rb", "spec/fsr/app/bridge.rb", "spec/fsr/app/conference.rb", "spec/fsr/app/execute_app.rb", "spec/fsr/app/fifo.rb", "spec/fsr/app/fs_break.rb", "spec/fsr/app/fs_sleep.rb", "spec/fsr/app/hangup.rb", "spec/fsr/app/limit.rb", "spec/fsr/app/log.rb", "spec/fsr/app/play_and_get_digits.rb", "spec/fsr/app/playback.rb", "spec/fsr/app/set.rb", "spec/fsr/app/transfer.rb", "spec/fsr/cmd.rb", "spec/fsr/cmd/calls.rb", "spec/fsr/cmd/originate.rb", "spec/fsr/cmd/sofia.rb", "spec/fsr/cmd/sofia/profile.rb", "spec/fsr/cmd/uuid_dump.rb", "spec/fsr/command_socket.rb", "spec/fsr/listener.rb", "spec/fsr/listener/inbound.rb", "spec/fsr/listener/outbound.rb", "spec/fsr/listener/response.rb", "spec/fsr/loading.rb", "spec/mock_listener.rb"]
  s.homepage = %q{http://code.rubyists.com/projects/fs}
  s.post_install_message = %q{# Freeswitcher

> An EventMachine-based Ruby library for interacting with the open source 
> telephony platform [FreeSWITCH](http://www.freeswitch.org).

## Prerequisites

Freeswitcher lets you interact with FreeSWITCH through mod_event_socket. You
should know how the event socket works, and the differences between inbound and
outbound event sockets before proceeding. The
[wiki page on mod_event_socket](http://wiki.freeswitch.org/wiki/Event_Socket) is
a good place to start.

## Inbound listener

To create an inbound listener, you should subclass `FSR::Listener::Inbound` and
add custom behaviour to it. An inbound listener subscribes to all events from
FreeSWITCH, and lets you react on events in two different ways:

1.      By overiding `on_event` which gets called every time an event arrives.

2.      By adding an event hook with `add_event_hook`, which will get called
        every time an event with the specified name arrives.

The header and content of the event is accessible through `event`.

Below is an example of an inbound listener utilising all the aforementioned
techniques:

    require 'fsr'
    require 'fsr/listener/inbound'

    class MyInbound < FSR::Listener::Inbound
      def on_event
        # Be sure to check out the content of `event`. It has all the good stuff.
        FSR::Log.info "Got event: #{event.content[:event_name]}"
      end
     
      # You can add a hook for a certain event:
      add_event_hook :CHANNEL_HANGUP do
        FSR::Log.info "Channel hangup!"
     
        # It is instance_eval'ed, so you can use your instance methods etc:
        do_something
      end
     
      def do_something
        ...
      end
    end

## Outbound listener

You create an outbound listener by subclassing `FSR::Listener::Outbound`. 

### Events

An outbound listener has the same event functionality as the inbound listener,
but it only recieves events related to that given session.

### Dialplan

When a call is made and Freeswitch connects to the outbound event listener,
`session_initiated` is called. This is where you set up your dialplan:

    def session_initiated
      answer
      set "some_var", "some value"
      playback "path/to/file"
      hangup
    end

When using applications that expects a reply, such as `play_and_get_digits`,
you have to use callbacks to read the value, as the function itself returns
immediately due to the async nature of EventMachine:

    def session_initiated
      answer

      play_and_get_digits "enter-number.wav", "error.wav" do |digit|
        FSR::Log.info "User pressed #{digit}"
        playback "thanks-for-the-input.wav"
        hangup
      end
    end

### Available applications

## Starting listeners

To start a single listener, connection/listening on localhost on the default
port is quite simple:

    FSR.start SomeListener

it takes an optional hash with arguments:

    FSR.start SomeListener, :host => "1.2.3.4", :port => "8087", :auth => "pwd"

Multiple listeners can be started at once by passing a block to `FSR.start`:

    FSR.start do
      run SomeListener
      run OtherListener, :port => "8080"
    end

## Originating a new call with `FSR::CommandSocket`

    >> require ‘fsr’
    => true
    
    >> FSR.load_all_commands
    => [:sofia, :originate]
    
    >> sock = FSR::CommandSocket.new
    => #<FSR::CommandSocket:0xb7a89104 @server=“127.0.0.1”,
        @socket=#<TCPSocket:0xb7a8908c>, @port=“8021”, @auth=“ClueCon”>
    
    >> sock.originate(:target => ‘sofia/gateway/carlos/8179395222’,
        :endpoint => FSR::App::Bridge.new(“user/bougyman”)).run
    => {“Job-UUID”=>“732075a4-7dd5-4258-b124-6284a82a5ae7”, “body”=>“”,
        “Content-Type”=>“command/reply”, 
        “Reply-Text”=>“+OK Job-UUID: 732075a4-7dd5-4258-b124-6284a82a5ae7”}


## Writing applications

## Extras

* Website: [http://code.rubyists.com/projects/fs](http://code.rubyists.com/projects/fs)
* Source: [http://gitorious.org/fsr](http://gitorious.org/fsr)
* Wiki: [http://gitorious.org/fsr/pages/Home](http://gitorious.org/fsr/pages/Home)
* IRC: #rubyists @ freenode

## License

(c) 2009 The Rubyists (Jayson Vaughn, Tj Vanderpoel, Michael Fellinger, Kevin Berry) 

Distributed under the terms of the MIT license.
}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{freeswitcher}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{A library for interacting with the "FreeSWITCH":http://freeswitch.org telephony platform}
  s.test_files = ["spec/fsr/app.rb", "spec/fsr/app/answer.rb", "spec/fsr/app/bind_meta_app.rb", "spec/fsr/app/bridge.rb", "spec/fsr/app/conference.rb", "spec/fsr/app/execute_app.rb", "spec/fsr/app/fifo.rb", "spec/fsr/app/fs_break.rb", "spec/fsr/app/fs_sleep.rb", "spec/fsr/app/hangup.rb", "spec/fsr/app/limit.rb", "spec/fsr/app/log.rb", "spec/fsr/app/play_and_get_digits.rb", "spec/fsr/app/playback.rb", "spec/fsr/app/set.rb", "spec/fsr/app/transfer.rb", "spec/fsr/cmd.rb", "spec/fsr/cmd/calls.rb", "spec/fsr/cmd/originate.rb", "spec/fsr/cmd/sofia.rb", "spec/fsr/cmd/sofia/profile.rb", "spec/fsr/cmd/uuid_dump.rb", "spec/fsr/command_socket.rb", "spec/fsr/listener.rb", "spec/fsr/listener/inbound.rb", "spec/fsr/listener/outbound.rb", "spec/fsr/listener/response.rb", "spec/fsr/loading.rb", "spec/mock_listener.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<eventmachine>, [">= 0"])
    else
      s.add_dependency(%q<eventmachine>, [">= 0"])
    end
  else
    s.add_dependency(%q<eventmachine>, [">= 0"])
  end
end
