require 'logger'
require 'socket'
require 'pathname'
require 'pp'

module FSR
  # Global configuration options
  #
  VERSION = '0.0.13'
  FS_INSTALL_PATHS = ["/usr/local/freeswitch", "/opt/freeswitch", "/usr/freeswitch"]
  DEFAULT_CALLER_ID_NUMBER = '8675309'
  DEFAULT_CALLER_ID_NAME   = "FSR"

  # Usage:
  #
  #   Log.info('foo')
  #   Log.debug('bar')
  #   Log.warn('foobar')
  #   Log.error('barfoo')
  Log = Logger.new($stdout)
  Log.level = Logger::INFO

  ROOT = Pathname(__FILE__).dirname.expand_path.freeze
  $LOAD_PATH.unshift(FSR::ROOT)

  # Load all FSR::Cmd classes
  def self.load_all_commands(retrying = false)
    require 'fsr/command_socket'
    load_all_applications
    Cmd.load_all
  end
  
  # Load all FSR::App classes
  def self.load_all_applications
    require "fsr/app"
    App.load_all
  end

  # Method to start EM for Outbound Event Socket
  def self.start_oes!(klass, args = {})
    port = args[:port] || "8084"
    host = args[:host] || "localhost"
    EM.run do
      EventMachine::start_server(host, port, klass)
      FSR::Log.info "*** FreeSWITCHer Outbound EventSocket Listener on #{host}:#{port} ***"
      FSR::Log.info "*** http://code.rubyists.com/projects/fs"
    end
  end
  
  # Method to start EM for Inbound Event Socket
  def self.start_ies!(klass, args = {})
    port = args[:port] || "8021"
    host = args[:host] || "localhost"
    EM.run do
      EventMachine::connect(host, port, klass)
      FSR::Log.info "*** FreeSWITCHer Inbound EventSocket Listener connected to #{host}:#{port} ***"
      FSR::Log.info "*** http://code.rubyists.com/projects/fs"
    end
  end

  private

  # Find the FreeSWITCH install path if running FSR on a local box with FreeSWITCH installed.
  # This will enable sqlite db access
  def self.find_freeswitch_install
    good_path = FS_INSTALL_PATHS.find do |fs_path|
      Log.warn("#{fs_path} is not a directory!") if File.exists?(fs_path) && !File.directory?(fs_path)
      Log.warn("#{fs_path} is not readable by this user!") if File.exists?(fs_path) && !File.readable?(fs_path)
      Dir["#{fs_path}/{conf,db}/"].size == 2
    end
    if good_path.nil?
      Log.warn("No FreeSWITCH install found, database and configuration functionality disabled")
      return nil
    end
  end

  FS_ROOT = find_freeswitch_install # FreeSWITCH $${base_dir}

  if FS_ROOT
    FS_CONFIG_PATH = (FS_ROOT + 'conf').freeze # FreeSWITCH conf dir
    FS_DB_PATH = (FS_ROOT + 'db').freeze       # FreeSWITCH db dir
  else
    FS_CONFIG_PATH = FS_DB_PATH = nil
  end
end

