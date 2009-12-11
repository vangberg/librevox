require 'fsr/cmd'

module FSR::Cmd
  class UuidBridge < Command
    def self.cmd_name
      "uuid_bridge"
    end

    attr_reader :arguments

    def initialize(leg1, leg2)
      @arguments = [leg1, leg2]
    end
  end
end
