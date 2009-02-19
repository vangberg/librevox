#!/usr/bin/env ruby

require 'rubygems'
require 'eventmachine'
require File.join(File.dirname(__FILE__), "..", 'lib', 'fsr')
require File.join(File.dirname(__FILE__), "..", 'lib', 'fsr', 'listener')
require File.join(File.dirname(__FILE__), "..", 'lib', 'fsr', 'listener', 'outbound')
FSR.load_all_applications

class OesDemo < FSR::Listener::Outbound
  def session_initiated(data)
    #transfer "user/bougyman"
    puts data.inspect
    #exit
  end
end
EM.run do
  port = 1888
  host = "127.0.0.1"
  EventMachine::start_server(host, port, OesDemo) 
  FSR::Log.debug "* FreeSWITCHer OES Listener on #{host}:#{port}"
end
