require 'socket'
require 'pp'
require 'lib/event'

module FreeSwitcher
  class EventSocket

    def initialize(socket)
      @socket = socket
    end

    # Send a command and return response
    def send(cmd)
      @socket.send("#{cmd}\n\n",0)
      return_result
    end

    # Send a command, do not return headers
    def <<(cmd)
      @socket.send("#{cmd}\n\n",0)
    end

    # Grab result from command
    def result
      lines = []
      until line = @socket.gets and line.chomp.empty?
         lines << line.chomp
      end
      lines.join("\n")
    end

    def return_result
      Event.from(result)
    end

  end
end
