module Librevox
  # All commands should call `execute_cmd` with the following parameters:
  #
  #   `name` - name of the command
  #   `args` - arguments as a string (optional)
  #
  # Commands *must* pass on any eventual block passed to them.
  module Commands
    def execute_cmd(name, args="", &block)
      msg = "api #{name}"
      msg << " #{args}" unless args.empty?

      run_cmd(msg, &block)
    end

    def status(&b)
      execute_cmd "status", &b
    end

    def originate(url, ext, args={})
      dialplan  = args.delete(:dialplan)
      context   = args.delete(:context)

      vars = args.map {|k,v| "#{k}=#{v}"}.join(",")

      arg_string = "{#{vars}}" + [url, ext, dialplan, context].compact.join(" ")
      execute_cmd "originate", arg_string
    end

    def fsctl(*args, &b)
      execute_cmd "fsctl", args.join(" "), &b
    end

    def hupall(cause=nil, &b)
      execute_cmd("hupall", cause, &b)
    end
  end
end
