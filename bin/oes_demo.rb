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
    number = session.headers["Channel-Caller-ID-Number"] # Grab the inbound caller id
    FSR::Log.info "*** Answering incoming call from #{number}"
    answer # Answer the call
    playback 'a_sound_file.wav'
    bridge "user/1001" # Bridge the call to "user/1001"
    hangup # Hangup the call
  end

end

FSR.start_oes!(OesDemo, :port => 8084, :host => "localhost")
