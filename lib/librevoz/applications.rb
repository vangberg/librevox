module Librevoz
  module Applications
    def execute_app(app, args=[], read_var=nil, &block)
      msg = "sendmsg\n"
      msg << "call-command: execute\n"
      msg << "execute-app-name: #{app}\n"
      msg << "execute-app-arg: %s\n" % args.join(" ") if args.any?

      run_app(msg, read_var, &block)
    end
  end
end
