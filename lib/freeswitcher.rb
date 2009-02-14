require 'logger'
require 'socket'
require 'pp'

module FreeSwitcher
  # Global configuration options
  #
  FS_ROOT = "/opt/freeswitch".freeze # Location of the freeswitch $${base_dir}
  FS_CONFIG_PATH = "/opt/freeswitch/conf".freeze # Freeswitch conf dir
  FS_DB_PATH = "/opt/freeswitch/db".freeze # Freeswitch db dir

  DEFAULT_CALLER_ID_NUMBER = '8675309'
  DEFAULT_CALLER_ID_NAME   = "FreeSwitcher"

  # Usage:
  #
  #   Log.info('foo')
  #   Log.debug('bar')
  #   Log.warn('foobar')
  #   Log.error('barfoo')
  Log = Logger.new($stdout)

  ROOT = File.expand_path(File.dirname(__FILE__)).freeze

  def self.load_all_commands
    @load_retry = true
    begin
      Commands.load_all
    rescue NameError
      if @load_retry
        @load_retry = false
        require "freeswitcher/command_socket"
        retry
      else
        raise
      end
    end
  end
end

$LOAD_PATH.unshift(FreeSwitcher::ROOT)

