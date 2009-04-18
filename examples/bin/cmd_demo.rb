#!/usr/bin/env ruby

require 'pp'
require File.join(File.dirname(__FILE__), "..", 'lib', 'fsr')
require "fsr/cmd"

FSR.load_all_commands
sock = FSR::CommandSocket.new

# Check the status of our server
pp sock.status.run

# Check max sessions
pp sock.fsctl.max_sessions
# Set max sessions
pp sock.fsctl.max_sessions = 3000

# Check up a sofia user
pp sock.sofia_contact(:contact => "internal/user@domain.com").run
