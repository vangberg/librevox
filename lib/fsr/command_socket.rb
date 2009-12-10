require 'socket'
require 'fsr/response'

module FSR
  class CommandSocket
    def self.register_cmd(klass)
      define_method klass.cmd_name do |*args|
        cmd = klass.new(*args)
        command cmd.raw
      end
    end

    def initialize(args={})
      @server = args[:server] || "127.0.0.1"
      @port   = args[:port] || "8021"
      @auth   = args[:auth] || "ClueCon"

      @socket = TCPSocket.open(@server, @port)

      command "auth #{@auth}"
    end

    def command(msg)
      @socket.print "#{msg}\n\n"
      read_response
    end

    def read_response
      response = FSR::Response.new
      response.headers = read_headers until response.command_reply?

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
