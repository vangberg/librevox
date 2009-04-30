#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__), "..", 'lib', 'fsr')
require "fsr/listener/outbound"
$stdout.flush

FSR.load_all_applications
FSR.load_all_commands
class PlayAndGetTest < FSR::Listener::Outbound

  def session_initiated
    exten = @session.headers[:caller_caller_id_number]
    FSR::Log.info "*** Answering incoming call from #{exten}"
    answer # Answer the call
  end

  def receive_reply(reply)
    exten = @session.headers[:caller_caller_id_number]
    case @step
    when 1
      FSR::Log.info "*** Reading dtmf for #{exten}"
      play_and_get_digits "/home/freeswitch/freeswitch/sounds/music/8000/sweet.wav","/home/freeswitch/freeswitch/sounds/en/us/callie/misc/8000/error.wav",4,10,3,10000,["#"],"test", '\d' # play_and_get_digits test
    when 2
      FSR::Log.info "*** updating session for #{exten}"
      update_session
    when 3
      FSR::Log.info "** Success, grabbed #{@session.headers[:variable_test]} from #{exten}"
      FSR::Log.info "*** Hanging up call"
      hangup # Hangup the call
    end
  end

end

FSR.start_oes! PlayAndGetTest, :port => 8084, :host => "127.0.0.1"
