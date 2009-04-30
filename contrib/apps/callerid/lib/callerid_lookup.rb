#!/usr/bin/env ruby

require "rubygems"
require "fsr"
$stdout.flush
require "fsr/listener/outbound"

class CalleridLookup < FSR::Listener::Outbound

  def session_initiated
    @inbound_number = @session.headers[:caller_caller_id_number] # Grab the inbound caller id
    @outbound_number = @session.headers[:caller_destination_number] # Grab the inbound caller id
    FSR::Log.info "*** Answering incoming call from #{@inbound_number} to #{@outbound_number}"
    answer
  end

  def receive_reply(session)
    case @step
    when 1
      # Lookup the current callerid number in a database and change it if we
      # have a number in the dialed area code for the group that owns
      # the callerid number
      if @inbound_number == "bougyman"
        set("effective_caller_id_number", "9724283101")
      else
        set("effective_caller_id_number", "9724283111")
      end
    when 2
      close_connection
    end
  end
end

FSR.start_oes!(CalleridLookup, :port => 1888, :host => "localhost") if $0 == __FILE__
