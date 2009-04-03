#!/usr/bin/env ruby

require 'rubygems'
require 'eventmachine'
require 'pp'
require File.join(File.dirname(__FILE__), "..", 'lib', 'fsr')
puts $LOAD_PATH.inspect
$stdout.flush
require "fsr/listener/inbound"


class IesDemo < FSR::Listener::Inbound

  def on_event(event)
    pp event
  end

end

FSR.start_ies!(IesDemo, :host => "localhost", :port => 8021)
