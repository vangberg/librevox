require 'logger'
require 'socket'
require 'pathname'
require 'pp'

module FreeSwitcher
  # Global configuration options
  #
  FS_INSTALL_PATHS = ["/usr/local/freeswitch", "/opt/freeswitch", "/usr/freeswitch"]
  DEFAULT_CALLER_ID_NUMBER = '8675309'
  DEFAULT_CALLER_ID_NAME   = "FreeSwitcher"

  # Usage:
  #
  #   Log.info('foo')
  #   Log.debug('bar')
  #   Log.warn('foobar')
  #   Log.error('barfoo')
  Log = Logger.new($stdout)

  ROOT = Pathname(__FILE__).dirname.expand_path.freeze

  def self.load_all_commands(retrying = false)
    require 'freeswitcher/command_socket'

    load_all_applications
    Commands.load_all
  end

  def self.load_all_applications
    require "freeswitcher/applications"
    Applications.load_all
  end

  private

  def self.find_freeswitch_install
    FS_INSTALL_PATHS.find{|fs_path| Dir["#{fs_path}/{conf,db}/"].size == 2 }
  end

  FS_ROOT = find_freeswitch_install # FreeSWITCH $${base_dir}

  raise("Couldn't find FreeSWITCH root path, searched: %p" % FS_INSTALL_PATHS) unless FS_ROOT

  FS_CONFIG_PATH = (FS_ROOT + 'conf').freeze # FreeSWITCH conf dir
  FS_DB_PATH = (FS_ROOT + 'db').freeze       # FreeSWITCH db dir
end

$LOAD_PATH.unshift(FreeSwitcher::ROOT)
