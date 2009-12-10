# Freeswitcher

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

You create An outbound listener by subclassing `FSR::Listener::Outbound`. 

### Events

An outbound listener has the same event functionality as the inbound listener,
but it only recieves events related to that given session.

### Dialplan

## Starting Freeswitcher

To start a single listener, connection/listening on localhost on the default
port is quite simple:

    FSR.start SomeListener

it takes an optional hash with arguments:

    FSR.start SomeListener, :host => "1.2.3.4", :port => "8087"

Multiple listeners can be started at once by passing a block to `FSR.start`:

   FSR.start do
     run SomeListener
     run OtherListener, :port => "8080"
   end

## Creating applications

## License

(c) 2009 The Rubyists (Jayson Vaughn, Tj Vanderpoel, Michael Fellinger, Kevin Berry) 

Distributed under the terms of the MIT license.
