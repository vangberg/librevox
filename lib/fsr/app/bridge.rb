require "fsr/app"

module FSR::App
  class Bridge < Application
    def initialize(*params)
      @options = params.last.is_a?(Hash) ? params.pop : {}
      @sequential = @options.delete(:sequential)
      @targets = params
    end

    def arguments
      delimeter = @sequential ? "|" : ","
      [@targets.join(delimeter)]
    end
  end

  register Bridge
end
