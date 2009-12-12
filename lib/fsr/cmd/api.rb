require 'fsr/cmd'

module FSR::Cmd
  class API < Command
    attr_reader :cmd_name, :arguments

    def initialize(cmd, *args)
      @cmd_name, @arguments = cmd, args
    end
  end

  register API
end
