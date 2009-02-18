#!/usr/bin/env ruby

require 'rubygems'
require 'eventmachine'
require File.join(File.dirname(__FILE__), "..", 'lib', 'fsr')
require File.join(File.dirname(__FILE__), "..", 'lib', 'fsr', 'listener')
require File.join(File.dirname(__FILE__), "..", 'lib', 'fsr', 'listener', 'outbound')

EM.run do
  port = 8084
  host = "127.0.0.1"
  EventMachine::start_server(host, port, FSR::Listener::Outbound)
  FSR::Log.debug "* FreeSWITCHer OES Listener on #{host}:#{port}"
end
