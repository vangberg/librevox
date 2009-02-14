require 'logger'
require 'socket'
require 'pp'

$LOAD_PATH.unshift(File.dirname(__FILE__))

module FreeSwitcher
  # Usage:
  #
  #   Log.info('foo')
  #   Log.debug('bar')
  #   Log.warn('foobar')
  #   Log.error('barfoo')
  Log = Logger.new($stdout)
end

require 'freeswitcher/event'
require 'freeswitcher/event_socket'
require 'freeswitcher/command_socket'
require 'freeswitcher/commands'
require 'freeswitcher/commands/originate'
