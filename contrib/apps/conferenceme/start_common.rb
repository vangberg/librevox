require 'rubygems'
require 'ramaze'

# Add directory start.rb is in to the load path, so you can run the app from
# any other working path
$LOAD_PATH.unshift(__DIR__)

# Initialize controllers and models
require 'controller/init'
require "fsr"
require "fsr/command_socket"
FSR.load_all_commands

