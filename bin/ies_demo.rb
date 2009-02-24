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
end

EM.run do
  EventMachine::connect("esther", 8021, IesDemo)
end
