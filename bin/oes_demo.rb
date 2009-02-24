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
    bridge "user/bougyman"
    puts "*** #{session.replies}"
    bridge "user/bougyman"
    puts "*** #{session.replies}"
    bridge "user/bougyman"
    puts "*** #{session.replies}"
  end
end

EM.run do
  port = 8084
  host = "192.168.6.32"
  EventMachine::start_server(host, port, OesDemo) 
  FSR::Log.debug "* FreeSWITCHer OES Listener on #{host}:#{port}"
end
