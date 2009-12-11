require 'socket'
require 'pathname'
require 'pp'

require 'fsr/listener'
require 'fsr/command_socket'

# Author::    TJ Vanderpoel (mailto:bougy.man@gmail.com)
# Copyright:: Copyright (c) 2009 The Rubyists (Jayson Vaughn, TJ Vanderpoel, Michael Fellinger, Kevin Berry)
# License::   Distributes under the terms of the MIT License http://www.opensource.org/licenses/mit-license.php

# This is ugly. But well, it'll eventually be removed.
def fsr_deprecate(old, new=nil)
  msg = "DEPRECATED: `#{old}` has been deprecated."
  msg += " Use `#{new}` instead." if new
  FSR::Log.warn msg
end

## This module declares the namespace under which the freeswitcher framework
## Any constants will be defined here, as well as methods for loading commands and applications
class Pathname
  def /(other)
    join(other.to_s)
  end
end
module FSR
  # Global configuration options
  FS_INSTALL_PATHS = ["/usr/local/freeswitch", "/opt/freeswitch", "/usr/freeswitch", "/home/freeswitch/freeswitch"]
  DEFAULT_CALLER_ID_NUMBER = '8675309'
  DEFAULT_CALLER_ID_NAME   = "FSR"

  #  attempt to require log4r.  
  #  if log4r is not available, load logger from stdlib
  begin
    require 'log4r'
    Log = Log4r::Logger.new('FSR')
    Log.outputters = Log4r::Outputter.stdout
    Log.level = Log4r::INFO
  rescue LoadError
    $stderr.puts "No log4r found, falling back to standard ruby library Logger"
    require 'logger'
    Log = Logger.new(STDOUT)
    Log.level = Logger::INFO
  end

  ROOT = Pathname(__FILE__).dirname.expand_path.freeze
  $LOAD_PATH.unshift(FSR::ROOT)

  # Load all FSR::Cmd classes
  def self.load_all_commands(retrying = false)
    require 'fsr/command_socket'
    Cmd.load_all
  end
  
  # When called without a block, it will start the listener that is passed as
  # first argument:
  #   
  #   FSR.start SomeListener
  #
  # To start multiple listeners, call with a block and use `run`:
  #
  #   FSR.start do
  #     run SomeListener
  #     run OtherListner
  #   end
  def self.start(klass=nil, args={}, &block)
    EM.run {
      block_given? ? instance_eval(&block) : run(klass, args)
    }
  end

  def self.run(klass, args={})
    host = args.delete(:host) || "localhost"
    port = args.delete(:port)

    if klass.ancestors.include? FSR::Listener::Inbound
      port ||= "8021"
      EM.connect host, port, klass, args
    elsif klass.ancestors.include? FSR::Listener::Outbound
      port ||= "8084"
      EM.start_server host, port, klass, args
    end
  end

  # Method to start EM for Outbound Event Socket
  def self.start_oes!(klass, args = {})
    fsr_deprecate "FSR.start_oes!", "FSR.start"

    port = args.delete(:port) || "8084"
    host = args.delete(:host) || "localhost"
    EM.run do
      EventMachine::start_server(host, port, klass, args)
      FSR::Log.info "*** FreeSWITCHer Outbound EventSocket Listener on #{host}:#{port} ***"
      FSR::Log.info "*** http://code.rubyists.com/projects/fs"
    end
  end
  
  # Method to start EM for Inbound Event Socket
  # @see FSR::Listener::Inbound
  # @param [FSR::Listener::Inbound] klass An Inbound Listener class, to be started by EM.run
  # @param [::Hash] args A hash of options, may contain
  #                       <tt>:host [String]</tt> The host/ip to bind to (Default: "localhost") 
  #                       <tt>:port [Integer]</tt> the port to listen on (Default: 8021)
  def self.start_ies!(klass, args = {})
    fsr_deprecate "FSR.start_ies!", "FSR.start"

    port = args.delete(:port) || "8021"
    host = args.delete(:host) || "localhost"
    EM.run do
      EventMachine::connect(host, port, klass, args)
      FSR::Log.info "*** FreeSWITCHer Inbound EventSocket Listener connected to #{host}:#{port} ***"
      FSR::Log.info "*** http://code.rubyists.com/projects/fs"
    end
  end


  # Find the FreeSWITCH install path if running FSR on a local box with FreeSWITCH installed.
  # This will enable sqlite db access
  def self.find_freeswitch_install
    good_path = FS_INSTALL_PATHS.find do |fs_path|
      FSR::Log.warn("#{fs_path} is not a directory!") if File.exists?(fs_path) && !File.directory?(fs_path)
      FSR::Log.warn("#{fs_path} is not readable by this user!") if File.exists?(fs_path) && !File.readable?(fs_path)
      Dir["#{fs_path}/{conf,db}/"].size == 2 ? fs_path.to_s : nil
    end
    FSR::Log.warn("No FreeSWITCH install found, database and configuration functionality disabled") if  good_path.nil?
    good_path
  end

  FS_ROOT = find_freeswitch_install # FreeSWITCH $${base_dir}

  if FS_ROOT
    FS_CONFIG_PATH = (FS_ROOT + 'conf').freeze # FreeSWITCH conf dir
    FS_DB_PATH = (FS_ROOT + 'db').freeze       # FreeSWITCH db dir
  else
    FS_CONFIG_PATH = FS_DB_PATH = nil
  end
end
require "fsr/version"

