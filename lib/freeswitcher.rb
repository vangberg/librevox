require 'socket'
require 'pp'

$LOAD_PATH.unshift(File.dirname(__FILE__))

module FreeSwitcher
end
require 'freeswitcher/event'
require 'freeswitcher/event_socket'
require 'freeswitcher/inbound_event_socket'
require 'freeswitcher/commands'
require 'freeswitcher/commands/originate'
