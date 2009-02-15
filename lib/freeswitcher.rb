require 'logger'
require 'socket'
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

  ROOT = File.expand_path(File.dirname(__FILE__)).freeze

  def self.load_all_commands
    @command_socket_load_retry = true
    begin
      load_all_applications
      Commands.load_all
    rescue NameError
      if @command_socket_load_retry
        @command_socket_load_retry = false
        require "freeswitcher/command_socket"
        retry
      else
        raise
      end
    end
  end

  def self.load_all_applications
    @application_load_retry = true 
    begin
      Applications.load_all
    rescue NameError
      if @application_load_retry
        @application_load_retry = false
        require "freeswitcher/applications"
        retry
      else
        raise
      end
    end
  end

  private
  def self.find_freeswitch_install
    FS_INSTALL_PATHS.detect do |fs_path|
      File.directory?(fs_path) and File.directory?(File.join(fs_path, "conf")) and File.directory?(File.join(fs_path, "db"))
    end
  end

  public
  FS_ROOT = find_freeswitch_install # Location of the freeswitch $${base_dir}
  raise "Could not find freeswitch root path, searched #{FS_INSTALL_PATHS.join(":")}" if FS_ROOT.nil?
  FS_CONFIG_PATH = File.join(FS_ROOT, "conf").freeze # Freeswitch conf dir
  FS_DB_PATH = File.join(FS_ROOT, "db").freeze # Freeswitch db dir

end

$LOAD_PATH.unshift(FreeSwitcher::ROOT)

