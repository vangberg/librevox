#!/usr/bin/env ruby

require 'rubygems'
require 'eventmachine'
require File.join(File.dirname(__FILE__), "..", 'lib', 'fsr')
puts $LOAD_PATH.inspect
$stdout.flush
require "fsr/listener/outbound"

module OesDemo
  include FSR::Listener::Outbound
  def session_initiated(session)
    bridge "user/1001"
    puts "*** #{session.replies}"
  end
end

FSR.start_oes!(OesDemo, :port => 8084, :host => "localhost")
