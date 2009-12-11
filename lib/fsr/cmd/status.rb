require 'fsr/cmd'

module FSR::Cmd
  class Status < Command
    def response=(r)
      @response = Response.new(r)
    end

    class Response
      def initialize(res)
        @response = res
        @lines = @response.content.lines.to_a
      end

      def uptime
        return @uptime if @uptime
        minutes, seconds = @lines[0].match(/(\d+) minutes, (\d+) seconds/).captures
        @uptime = minutes.to_i * 60 + seconds.to_i
      end

      def sessions
        return @sessions if @sessions
        current, max = @lines[2].match(/(\d+)\/(\d+)$/).captures
        @sessions = [current.to_i, max.to_i]
      end
    end
  end

  register Status
end
