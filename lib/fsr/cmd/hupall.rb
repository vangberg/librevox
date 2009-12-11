require 'fsr/cmd'

module FSR::Cmd
  class Hupall < Command
    def initialize(cause=nil)
      @cause = cause
    end

    def arguments
      [@cause]
    end
  end

  register Hupall
end
