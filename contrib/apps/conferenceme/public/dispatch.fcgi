#!/usr/bin/env ruby

require 'rubygems'
require 'ramaze'

# FCGI doesn't like you writing to stdout
Ramaze::Log.loggers = [ Ramaze::Logger::Informer.new( File.join(__DIR__, '..', "log", 'ramaze.fcgi.log') ) ]
Ramaze::Global.adapter = :fcgi

start_common = File.join(__DIR__, '..', 'start_common')
require start_common
Ramaze.start :sourcereload => false, :adapter => :fcgi, :load_engines => [:Haml, :Erubis, :Ezamar]
