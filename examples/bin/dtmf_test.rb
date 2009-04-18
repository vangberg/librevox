#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), "..", 'start_common')
require 'eventmachine'
require "fsr/listener/outbound"
require 'pp'
$stdout.flush
FSR.load_all_applications
FSR.load_all_commands
class ConsumerLogin < FSR::Listener::Outbound

  def session_initiated(session, step = 0)
    @step ||= step
    exten = session.headers[:channel_caller_id_number]
    pp session.headers
    FSR::Log.info "*** Answering incoming call from #{exten}"
    answer # Answer the call
  end

  def receive_reply(reply)
    exten = @session.headers[:channel_caller_id_number]
    @step += 1
    case @step
    when 1
      FSR::Log.info "*** Reading dtmf for #{exten}"
      read "/home/freeswitch/freeswitch/sounds/music/8000/sweet.wav",4,10,"test",15000 # read test
    when 2
      FSR::Log.info "*** updating session for #{exten}"
      update_session
    when 3
      FSR::Log.info "** Success, grabbed #{reply.content[:variable_test].strip} from #{exten}"
      FSR::Log.info "*** Hanging up call"
      hangup # Hangup the call
    end
  end

end

FSR.start_oes! ConsumerLogin, :port => 8084, :host => "127.0.0.1"
