require 'socket'
require 'pathname'
require 'pp'

require 'fsr/listener'
require 'fsr/command_socket'

# Author::    TJ Vanderpoel (mailto:bougy.man@gmail.com)
# Copyright:: Copyright (c) 2009 The Rubyists (Jayson Vaughn, TJ Vanderpoel, Michael Fellinger, Kevin Berry)
# License::   Distributes under the terms of the MIT License http://www.opensource.org/licenses/mit-license.php

module FSR
  # Global configuration options
  FS_INSTALL_PATHS = ["/usr/local/freeswitch", "/opt/freeswitch", "/usr/freeswitch", "/home/freeswitch/freeswitch"]

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
