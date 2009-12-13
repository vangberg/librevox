module Librevox
  # All applications should call `execute_app` with the following parameters:
  #
  #   `name` - name of the application
  #   `args` - arguments as a string (optional)
  #   `params` - optional hash (optional)
  #
  # Applications *must* pass on any eventual block passed to them.
  module Applications
    def answer(&b)
      execute_app "answer", &b
    end

    def bridge(*endpoints, &b)
      execute_app "bridge", endpoints.join(","), &b
    end

    def playback(file, &b)
      execute_app "playback", file, &b
    end

    def play_and_get_digits(file, invalid_file, args={}, &b)
      min         = args[:min]          || 1
      max         = args[:max]          || 2
      tries       = args[:tries]        || 3
      terminators = args[:terminators]  || "#"
      timeout     = args[:timeout]      || 5000
      read_var    = args[:read_var]     || "read_digits_var"
      regexp      = args[:regexp]       || "\\d+"

      args = [min, max, tries, timeout, terminators, file, invalid_file,
        read_var, regexp].join " "

      params = {:read_var => read_var}

      execute_app "play_and_get_digits", args, params, &b
    end

    def read(file, args={}, &b)
      min         = args[:min]          || 1
      max         = args[:max]          || 2
      terminators = args[:terminators]  || "#"
      timeout     = args[:timeout]      || 5000
      read_var    = args[:read_var]     || "read_digits_var"

      arg_string = "%s %s %s %s %s %s" % [min, max, file, read_var, timeout,
        terminators]

      params = {:read_var => read_var}

      execute_app "read", arg_string, params, &b
    end

    def bind_meta_app(args={}, &b)
      key         = args[:key]
      listen_to   = args[:listen_to]
      respond_on  = args[:respond_on]
      application = args[:application]
      parameters  = args[:parameters] ? "::#{args[:parameters]}" : ""

      arg_string = "%s %s %s %s%s" % [key, listen_to, respond_on, application,
        parameters]

      execute_app "bind_meta_app", arg_string, &b
    end

    def transfer(extension, &b)
      execute_app "transfer", extension, &b
    end

    def record(path, params={}, &b)
      args = [path, params[:limit]].compact.join(" ")
      execute_app "record", args, &b
    end

    def set(variable, value, &b)
      execute_app "set", "#{variable}=#{value}", &b
    end

    def hangup(cause="", &b)
      execute_app "hangup", cause, &b
    end
  end
end
