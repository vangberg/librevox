#!/usr/bin/env ruby

require 'rubygems'
require 'eventmachine'
require 'pp'
require File.join(File.dirname(__FILE__), "..", 'lib', 'fsr')
puts $LOAD_PATH.inspect
$stdout.flush
require "fsr/listener/inbound"


module IesDemo
  include FSR::Listener::Inbound

  def on_event(event)
    pp event
  end

end

FSR.start_ies!(IesDemo, :host => "pip", :port => 8021, :secret => "pip_clue")
