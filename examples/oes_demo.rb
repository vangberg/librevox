#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__), "..", 'lib', 'fsr')
puts $LOAD_PATH.inspect
$stdout.flush
require "fsr/listener/outbound"

class OesDemo < FSR::Listener::Outbound

  def session_initiated(session)
    number = session.headers[:caller_caller_id_number] # Grab the inbound caller id
    FSR::Log.info "*** Answering incoming call from #{number}"
    answer # Answer the call
    log("1", "Pong from the FSR event socket!")
    set("hangup_after_bridge", "true") # Set a variable
    speak 'Hello, This is your phone switch. Have a great day' # use mod_flite to speak
    hangup # Hangup the call
  end

end

FSR.start_oes!(OesDemo, :port => 1888, :host => "localhost")
