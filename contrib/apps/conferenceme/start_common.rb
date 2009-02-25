require 'rubygems'
require 'ramaze'

# Add directory start.rb is in to the load path, so you can run the app from
# any other working path
$LOAD_PATH.unshift(__DIR__)

# Initialize controllers and models
require "fsr"
require "fsr/command_socket"
require 'controller/init'
require 'model/init'

FSR.load_all_commands
