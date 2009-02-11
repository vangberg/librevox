module FreeSwitcher
  module Commands
    @commands = []
    def self.register_command(command)
      @commands << command
    end

    def list
      @commands
    end
  end
end
