#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__), "..", 'lib', 'fsr')
require "fsr/listener/outbound"
$stdout.flush

class OutboundDemo < FSR::Listener::Outbound

  def session_initiated
    exten = @session.headers[:caller_caller_id_number]
    FSR::Log.info "*** Answering incoming call from #{exten}"

    answer do
      FSR::Log.info "***Reading DTMF from #{exten}"
      read("/home/freeswitch/freeswitch/sounds/music/8000/sweet.wav", 4, 10, "input", 7000) do
        FSR::Log.info "*** Updating session for #{exten}"
        update_session do
          FSR::Log.info "***Success, grabbed #{@session.headers[:variable_input].strip} from #{exten}"
          hangup #Hangup the call
        end
      end
    end

  end

end

FSR.start_oes! OutboundDemo, :port => 8084, :host => "127.0.0.1"
