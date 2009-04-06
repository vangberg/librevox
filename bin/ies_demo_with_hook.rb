#!/usr/bin/env ruby

require 'pp'
require File.join(File.dirname(__FILE__), "..", 'lib', 'fsr')
puts $LOAD_PATH.inspect
$stdout.flush
require "fsr/listener/inbound"

# This adds a hook on CHANNEL_CREATE events
FSL::Inbound.add_event_hook(:CHANNEL_CREATE) {|event| FSR::Log.info "*** [#{event.content[:unique_id]}} Channel created - greetings from the hook!" }

# Start FSR Inbound Listener
FSR.start_ies!(FSL::Inbound, :host => "localhost", :port => 8021)

