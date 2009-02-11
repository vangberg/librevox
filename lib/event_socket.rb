require 'socket'
require 'pp'
require File.join(File.dirname(__FILE__), 'event')

module FreeSwitcher
  class EventSocket
    attr_reader :socket

    def initialize(socket)
      @socket = socket
    end

    # Send a command and return response
    def send(cmd)
      @socket.send("#{cmd}\n\n",0)
      response
    end

    # Send a command, do not return response
    def <<(cmd)
      @socket.send("#{cmd}\n\n",0)
    end

    # Grab result from command
    def result
      lines = []
      until line = @socket.gets and line.chomp.empty?
         lines << line.chomp
      end
      lines
    end
    
    # Scrub result into a hash
    def response
      result
      #Event.from(result)
    end

  end
end
