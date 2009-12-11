require 'fsr/cmd'

module FSR::Cmd
  class DomainExists < Command
    def self.cmd_name
      "domain_exists"
    end

    def initialize(domain)
      @domain = domain
    end

    def arguments
      [@domain]
    end

    def response=(response)
      @response = response.content == "true"
    end
  end
  
  register DomainExists
end
