module Librevox
  # All applications should call `execute_app` with the following parameters:
  #
  #   `name` - name of the application
  #   `args` - arguments as a string (optional)
  #   `params` - optional hash (optional)
  #
  # Applications *must* pass on any eventual block passed to them.
  module Applications
    # Answers an incoming call or session.
    def answer(&b)
      execute_app "answer", &b
    end

    # Binds an application to the specified call legs.
    # @example 
    #   bind_meta_app :key          => 2,
    #                 :listen_to    => "a",
    #                 :respond_on   => "s",
    #                 :application  => "execute_extension",
    #                 :parameters   => "dx XML features"
    # @see http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_bind_meta_app
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

    # Bridges an incoming call to an endpoint
    # @example
    #   bridge "user/coltrane", "user/backup-office"
    # @see http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_bridgecall
    def bridge(*endpoints, &b)
      execute_app "bridge", endpoints.join(","), &b
    end

    def hangup(cause="", &b)
      execute_app "hangup", cause, &b
    end

    # Plays a sound file and reads DTMF presses.
    # @example 
    #   play_and_get_digits "please-enter.wav", "wrong-choice.wav",
    #     :min          => 1,
    #     :max          => 2,
    #     :tries        => 3,
    #     :terminators  => "#",
    #     :timeout      => 5000,
    #     :regexp       => '\d+'
    # @see http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_play_and_get_digits
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

    # Plays a sound file on the current channel.
    # @example
    #   playback "/path/to/file.wav"
    # @see http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_playback
    def playback(file, &b)
      execute_app "playback", file, &b
    end

    # @see http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_read
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

    # Records a message, with an optional limit on the maximum duration of the
    # recording.
    # @example Without limit
    #   record "/path/to/new/file.wac"
    # @example With 20 second limit
    #   record "/path/to/new/file.wac", :limit => 20
    # @see http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_record
    def record(path, params={}, &b)
      args = [path, params[:limit]].compact.join(" ")
      execute_app "record", args, &b
    end

    # Sets a channel variable.
    # @example
    #   set "some_var", "some value"
    # @see http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_set
    def set(variable, value, &b)
      execute_app "set", "#{variable}=#{value}", &b
    end

    # Transfers the current channel to a new context.
    # @example
    #   transfer "new_context"
    # @see http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_transfer
    def transfer(context, &b)
      execute_app "transfer", context, &b
    end
  end
end
