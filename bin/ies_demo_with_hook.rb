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

# This adds a hook on CHANNEL_CREATE events
FSR::Listener::Inbound.add_event_hook(:CHANNEL_CREATE) {|event| FSR::Log.info "*** [#{event['Unique-ID']}} Channel created - greetings from the hook!" }

FSR.start_ies!(IesDemo, :host => "kitty", :port => 8021, :secret => "ClueCon")

