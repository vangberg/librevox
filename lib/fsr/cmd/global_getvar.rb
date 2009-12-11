require 'fsr/cmd'

module FSR::Cmd
  class GlobalGetvar < Command
    def self.cmd_name
      "global_getvar"
    end

    attr_reader :arguments

    def initialize(var)
      @arguments = [var]
    end

    def response=(r)
      @response = r.content
    end
  end
end
