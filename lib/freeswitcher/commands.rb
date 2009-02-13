require File.join(File.dirname(__FILE__), "..", "freeswitcher") unless Object.const_defined?("FreeSwitcher")
require File.join(File.dirname(__FILE__), "inbound_event_socket") unless FreeSwitcher.const_defined?("InboundEventSocket")
module FreeSwitcher
  module Commands
    @commands = []
    def self.register(command, obj)
      @commands << [command, obj]
      FreeSwitcher::InboundEventSocket.class_eval(<<RUBY
        def #{command} (args = {})
          #{obj}.new(self, args) 
        end
RUBY
)
    end

    def self.list
      @commands.map { |n| n.first }
    end

  end
end
