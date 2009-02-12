require File.join(File.dirname(__FILE__), "..", "freeswitcher") unless Object.const_defined?("FreeSwitcher")
module FreeSwitcher
  module Commands
    @commands = []
    def self.register(command, obj)
      @commands << [command, obj]
    end

    def self.list
      @commands.map { |n| n.first }
    end

  end
end
