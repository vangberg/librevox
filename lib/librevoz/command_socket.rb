require 'socket'
require 'librevoz/response'
require 'librevoz/commands'
require 'librevoz/applications'

module Librevoz
  class CommandSocket
    include Librevoz::Commands
    include Librevoz::Applications

    def initialize(args={})
      @server   = args[:server] || "127.0.0.1"
      @port     = args[:port] || "8021"
      @auth     = args[:auth] || "ClueCon"

      connect unless args[:connect] == false
    end

    def connect
      @socket = TCPSocket.open(@server, @port)
      run_cmd "auth #{@auth}"
    end

    def run_cmd(cmd)
      @socket.print "#{cmd}\n\n"
      read_response
    end

    def execute_app(app, args=[], params={})
      "&#{app}(#{args.join(" ")})"
    end

    def read_response
      response = Librevoz::Response.new
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
  end
end
