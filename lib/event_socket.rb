require 'socket'
require 'pp'
require 'yaml'
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
    def get_header
      lines = []
      until line = @socket.gets and line.chomp.empty?
         lines << line.chomp
      end
      lines.join("\n")
    end

    def get_content(header)
      bytes = YAML.load(header)["Content-Length"]
      bytes = 0 if bytes.nil?
      header << "\n\n" << @socket.read(bytes) if bytes > 0
      header
    end
    
    # Scrub result into a hash
    def response
      result = get_content(get_header)
      #Event.from(result)
    end

  end
end
