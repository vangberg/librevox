module Librevoz
  module Commands
    def make_cmd(cmd, *args, &block)
      msg = "api #{cmd}"
      msg += " #{args.join(" ")}" if args.any?

      run_cmd(msg, &block)
    end
  end
end
