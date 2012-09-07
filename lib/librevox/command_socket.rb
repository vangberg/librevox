require 'socket'
require 'librevox/response'
require 'librevox/commands'
require 'librevox/applications'

module Librevox
  class CommandSocket
    include Librevox::Commands

    def initialize args={}
      @server   = args[:server] || "127.0.0.1"
      @port     = args[:port] || "8021"
      @auth     = args[:auth] || "ClueCon"

      connect unless args[:connect] == false
    end

    def connect
      @socket = TCPSocket.open(@server, @port)
      @socket.print "auth #{@auth}\n\n"
      read_response
    end

    def command *args
      @socket.print "#{super(*args)}\n\n"
      read_response
    end

    def read_response
      response = Librevox::Response.new
      until response.command_reply? or response.api_response?
        response.headers = read_headers 
      end

      length = response.headers[:content_length].to_i
      response.content = @socket.read(length) if length > 0

      response
    end

    def read_headers
      headers = ""

      while line = @socket.gets and !line.chomp.empty?
        headers += line
      end

      headers
    end

    def close
      @socket.close
    end
  end
end
