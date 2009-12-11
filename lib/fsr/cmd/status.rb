require 'fsr/cmd'

module FSR::Cmd
  class Status < Command
    def response=(r)
      @response = Response.new(r)
    end

    class Response
      MINUTE  = 60
      HOUR    = 60 * MINUTE
      DAY     = 24 * HOUR
      YEAR    = 365 * DAY

      def initialize(response)
        @response = response
        @lines = @response.content.lines.to_a
      end

      # This isn't pretty..
      def uptime
        return @uptime if @uptime
        arr = @lines[0].split.map {|w| w.to_i}
        @uptime = arr[1] * YEAR + arr[3] * DAY + arr[5] * HOUR + arr[7] * MINUTE + arr[9]
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
