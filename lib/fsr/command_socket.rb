require 'socket'
require 'fsr/response'

module FSR
  class CommandSocket
    include Cmd

    def self.register_cmd(klass)
      define_method klass.cmd_name do |*args|
        cmd = klass.new(*args)
        run(cmd)
      end
    end

    def initialize(args={})
      @server   = args[:server] || "127.0.0.1"
      @port     = args[:port] || "8021"
      @auth     = args[:auth] || "ClueCon"

      connect unless args[:connect] == false
    end

    def connect
      @socket = TCPSocket.open(@server, @port)
      command "auth #{@auth}"
    end

    def socket
    end

    def run(cmd)
      cmd.response = command(cmd.raw)
      cmd.response
    end

    def command(msg)
      @socket.print "#{msg}\n\n"
      read_response
    end

    def read_response
      response = FSR::Response.new
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

require 'fsr/cmd'
