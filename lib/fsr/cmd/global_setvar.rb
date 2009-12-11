require 'fsr/cmd'

module FSR::Cmd
  class GlobalSetvar < Command
    def self.cmd_name
      "global_setvar"
    end

    attr_reader :arguments

    def initialize(var, value)
      @arguments = ["#{var}=#{value}"]
    end
  end
end
