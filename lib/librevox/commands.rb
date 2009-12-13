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

    def originate(url, ext, vars={})
      vars = vars.map {|k,v| "#{k}=#{v}"}.join(",")
      args = "{%s}%s %s" % [vars, url, ext]
      execute_cmd "originate", args
    end

    def fsctl(*args, &b)
      execute_cmd "fsctl", args.join(" "), &b
    end

    def hupall(cause=nil, &b)
      execute_cmd("hupall", cause, &b)
    end
  end
end
