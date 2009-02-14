require File.join(File.dirname(__FILE__), "..", "freeswitcher") unless Object.const_defined?("FreeSwitcher")
require File.join(File.dirname(__FILE__), "command_socket") unless FreeSwitcher.const_defined?("CommandSocket")

module FreeSwitcher
  module Commands
    COMMANDS = {}

    def self.register(command, obj)
      COMMANDS[command.to_sym] = obj

      code = "def %s(*args, &block) COMMANDS[%p].new(self, *args, &block) end" % [command, command]
      Commands.module_eval(code)
    end

    def self.list
      COMMANDS.keys
    end
  end
end
