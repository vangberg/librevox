module FSR
  module Cmd
    class Command
    end

    COMMANDS = {}
    LOAD_PATH = [File.join(FSR::ROOT, "fsr", "cmd")]

    def self.register(command, obj)
      COMMANDS[command.to_sym] = obj

      code = "def %s(*args, &block) COMMANDS[%p].new(self, *args, &block) end" % [command, command]
      Cmd.module_eval(code)
    end

    def self.list
      COMMANDS.keys
    end

    def self.load_command(command, force_reload = false)
      # If we get a path specification and it's an existing file, load it
      if File.file?(command)
        if force_reload
          return load(command)
        else
          return require(command)
        end
      end

      # If we find a file named the same as the command passed in LOAD_PATH, load it
      if command_file = LOAD_PATH.detect { |command_path| File.file?(File.join(command_path, "#{command}.rb")) }
        if force_reload
          load command_file
        else
          require command_file
        end
      else
        raise "#{command} not found in #{LOAD_PATH.join(":")}"
      end
    end

    # Load all of the commands we find in Cmd::LOAD_PATH
    def self.load_all(force_reload = false)
      LOAD_PATH.each do |load_path|
        Dir[File.join(load_path, "*.rb")].each { |command_file| load_command(command_file, force_reload) }
      end
      list
    end

    def commands
      FSR::Cmd.list
    end
  end
end
