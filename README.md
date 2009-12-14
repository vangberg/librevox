# Librevox

> An EventMachine-based Ruby library for interacting with the open source 
> telephony platform [FreeSWITCH](http://www.freeswitch.org).

Librevox eventually came to life during a major rewrite of
[Freeswitcher](http://code.rubyists.com/projects/fs/). Not everything would
fit into the existing architecture, and I felt that a blank slate was needed.
Librevox and Freeswitcher looks much alike on the outside, but Librevox tries
to take a simpler approach on the inside. Eventually this is still beta
software, and needs some real-life testing before seeing a regular release.

## Prerequisites

Librevox lets you interact with FreeSWITCH through mod_event_socket. You
should know how the event socket works, and the differences between inbound and
outbound event sockets before proceeding. The
[wiki page on mod_event_socket](http://wiki.freeswitch.org/wiki/Event_Socket) is
a good place to start.

## Inbound listener

To create an inbound listener, you should subclass `Librevox::Listener::Inbound`
and add custom behaviour to it. An inbound listener subscribes to all events
from FreeSWITCH, and lets you react on events in two different ways:

1.      By overiding `on_event` which gets called every time an event arrives.

2.      By adding an event hook with `event`, which will get called every time
        an event with the specified name arrives.

The header and content of the event is accessible through `event`.

Below is an example of an inbound listener utilising all the aforementioned
techniques:

    require 'librevox'

    class MyInbound < Librevox::Listener::Inbound
      def on_event
        puts "Got event: #{event.content[:event_name]}"
      end
     
      # You can add a hook for a certain event:
      event :channel_hangup do
        # It is instance_eval'ed, so you can use your instance methods etc:
        do_something
      end
     
      def do_something
        ...
      end
    end

## Outbound listener

You create an outbound listener by subclassing `Librevox::Listener::Outbound`. 

### Events

An outbound listener has the same event functionality as the inbound listener,
but it only receives events related to that given session.

### Dialplan

When a call is made and Freeswitch connects to the outbound event listener,
the `session` callback is executed. This is where you set up your dialplan:

    session do
      answer
      set "some_var", "some value"
      playback "path/to/file"
      hangup
    end

When using applications that expects a reply, such as `play_and_get_digits`,
you have to use callbacks to read the value, as the function itself returns
immediately due to the async nature of EventMachine:

    session do
      answer

      play_and_get_digits "enter-number.wav", "error.wav" do |digit|
        puts "User pressed #{digit}"
        playback "thanks-for-the-input.wav"
        hangup
      end
    end

## Starting listeners

To start a single listener, connection/listening on localhost on the default
port is quite simple:

    Librevox.start SomeListener

it takes an optional hash with arguments:

    Librevox.start SomeListener, :host => "1.2.3.4", :port => "8087", :auth => "pwd"

Multiple listeners can be started at once by passing a block to `Librevox.start`:

    Librevox.start do
      run SomeListener
      run OtherListener, :port => "8080"
    end

## Using `Librevox::CommandSocket`

Librevox also ships with a CommandSocket class, which allows you to connect
to the FreeSWITCH management console, from which you can originate calls,
restart FreeSWITCH etc.

    >> require `librevox`
    => true
    
    >> socket = Librevox::CommandSocket.new
    => #<Librevox::CommandSocket:0xb7a89104 @server=“127.0.0.1”,
        @socket=#<TCPSocket:0xb7a8908c>, @port=“8021”, @auth=“ClueCon”>

    >> socket.originate('sofia/user/coltrane', :extension => "1234")
    >> #<Librevox::Response:0x10179d388 @content="+OK de0ecbbe-e847...">
    
    >> socket.status
    >> > #<Librevox::Response:0x1016acac8 ...>

## Further documentation

All applications and commands are documented in the code. You can run
`yardoc` from the root of the source tree to generate YARD docs. Look under
the `Librevox::Commands` and `Librevox::Applications` modules.

## Extras

* Source: [http://github.com/ichverstehe/librevox](http://github.com/ichverstehe/librevox)
* API docs: [http://rdoc.info/projects/ichverstehe/librevox](http://rdoc.info/projects/ichverstehe/librevox)
* Mailing list: librevox@librelist.com
* IRC: #librevox @ irc.freenode.net

## License

(c) 2009 Harry Vangberg <harry@vangberg.name>

Librevox was inspired by and uses code from Freeswitcher, which is distributed
under the MIT license and (c) 2009 The Rubyists (Jayson Vaughn, Tj Vanderpoel,
Michael Fellinger, Kevin Berry), Harry Vangberg

Distributed under the terms of the MIT license.
