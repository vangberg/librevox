require 'fsr/cmd'

module FSR::Cmd
  class Load < Command
    attr_reader :arguments

    def initialize(mod)
      @arguments = [mod]
    end
  end
end
