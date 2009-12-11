require 'fsr/cmd'

module FSR::Cmd
  class Reload < Command
    def initialize(mod, args={})
      @module = mod
      @force = "-f" if args[:force] 
    end

    def arguments
      [@force, @module].compact
    end
  end
end
