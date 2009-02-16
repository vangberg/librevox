require 'logger'
require 'socket'
require 'pathname'
require 'pp'

module FSR
  # Global configuration options
  #
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

  ROOT = Pathname(__FILE__).dirname.expand_path.freeze

  def self.load_all_commands(retrying = false)
    require 'fsr/command_socket'

    load_all_applications
    Cmd.load_all
  end

  def self.load_all_applications
    require "fsr/app"
    App.load_all
  end

  private

  def self.find_freeswitch_install
    FS_INSTALL_PATHS.find do |fs_path|
      raise("#{fs_path} is not a directory!") if File.exists?(fs_path) && !File.directory?(fs_path)
      raise("#{fs_path} is not readable by this user!") if File.exists?(fs_path) && !File.readable?(fs_path)
      Dir["#{fs_path}/{conf,db}/"].size == 2
    end
  end

  FS_ROOT = find_freeswitch_install # FreeSWITCH $${base_dir}

  raise("Couldn't find FreeSWITCH root path, searched: %p" % FS_INSTALL_PATHS) unless FS_ROOT

  FS_CONFIG_PATH = (FS_ROOT + 'conf').freeze # FreeSWITCH conf dir
  FS_DB_PATH = (FS_ROOT + 'db').freeze       # FreeSWITCH db dir
end

$LOAD_PATH.unshift(FSR::ROOT)
