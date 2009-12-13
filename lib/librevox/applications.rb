module Librevox
  # All applications should call `execute_app` with the following parameters:
  #
  #   `name` - name of the application
  #   `args` - arguments as a string
  #   `params` - optional hash
  #
  # Applications *must* pass on any eventual block passed to them.
  module Applications
    def answer(&b)
      execute_app "answer", &b
    end

    def bridge(*endpoints, &b)
      execute_app "bridge", endpoints.join(","), &b
    end

    def play_and_get_digits(file, invalid_file, params={}, &b)
      min         = params[:min]          || 1
      max         = params[:max]          || 2
      tries       = params[:tries]        || 3
      terminators = params[:terminators]  || "#"
      timeout     = params[:timeout]      || 5000
      read_var    = params[:read_var]     || "read_digits_var"
      regexp      = params[:regexp]       || "\\d+"

      args = "%s %s %s %s %s %s %s %s %s" % [min, max, tries, timeout,
        terminators, file, invalid_file, read_var, regexp]

      params = {:read_var => read_var}

      execute_app "play_and_get_digits", args, params, &b
    end

    def hangup(cause="", &b)
      execute_app "hangup", cause, &b
    end
  end
end
