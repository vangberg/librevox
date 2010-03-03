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
    # @see http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_answer
    def answer &b
      execute_app "answer", &b
    end

    # Make an attended transfer
    # @example
    #   att_xfer("user/davis")
    # @see http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_att_xfer
    # @todo Add support for origination_cancel_key
    def att_xfer endpoint, &b
      execute_app "att_xfer", endpoint, &b
    end

    # Binds an application to the specified call legs.
    # @example 
    #   bind_meta_app :key          => 2,
    #                 :listen_to    => "a",
    #                 :respond_on   => "s",
    #                 :application  => "execute_extension",
    #                 :parameters   => "dx XML features"
    # @see http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_bind_meta_app
    def bind_meta_app args={}, &b
      arg_string =
        args.values_at(:key, :listen_to, :respond_on, :application).join(" ")
      arg_string += "::#{args[:parameters]}" if args[:parameters]

      execute_app "bind_meta_app", arg_string, &b
    end


    # Bridges an incoming call to an endpoint, optionally taking an array of
    # channel variables to set. If given an array of arrays, each contained
    # array of endpoints will be called simultaneously, with the next array
    # of endpoints as failover. See the examples below for different constructs
    # and the callstring it sends to FreeSWITCH.
    # @example
    #   bridge "user/coltrane", "user/backup-office"
    #   #=> user/coltrane,user/backup-office
    # @example With channel variables
    #   bridge "user/coltrane", "user/backup-office", :some_var => "value"
    #   #=> {some_var=value}user/coltrane,user/backup-office
    # @example With failover
    #   bridge ['user/coltrane', 'user/davis'], ['user/sun-ra', 'user/taylor']
    #   #=> user/coltrane,user/davis|user/sun-ra,user/taylor
    # @see http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_bridgecall
    def bridge *args, &b
      variables = if args.last.is_a? Hash
                    # We need to sort the key/value pairs to facilitate testing.
                    # This can be removed once 1.8-compat is dropped.
                    key_value_pairs = args.pop.sort {|x,y| x.to_s <=> y.to_s}
                    key_value_pairs.map! {|k,v| "#{k}=#{v}"}
                    "{#{key_value_pairs.join(",")}}"
                  else
                    ""
                  end

      endpoints = if args.first.is_a? Array
                    args.map {|e| e.join(",")}.join("|")
                  else
                    args.join ","
                  end

      execute_app "bridge", variables + endpoints, &b
    end

    # Deflect a call by sending a REFER. Takes a SIP URI as argument, rerouting
    # the call to that SIP URI.
    #
    # Beware that REFER only can be used on established calls. If a call hasn't
    # been established with e.g. the {#answer} application, you should use 
    # {#redirect} instead.
    # @example
    #   deflect "sip:miles@davis.com"
    # @see #redirect
    # @see http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_deflect
    def deflect uri, &b
      execute_app "deflect", uri, &b
    end

    # Exports a channel variable from the A leg to the B leg. Variables and
    # their values will be replicated in any new channels created from the one
    # export was called.
    # 
    # Set :local => false if the variable should only be exported to the B-leg.
    #
    # @example
    #   export "some_var"
    # @example Only export to B-leg
    #   export "some_var", :local => false
    # @see http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_export
    def export var, args={}, &b
      nolocal = args[:local] == false ? "nolocal:" : "" # ugly!!111

      execute_app "export", "#{nolocal}#{var}", &b
    end

    # Generate TGML tones
    # @example Generate a 500ms beep at 800Hz
    #   gentones "%(500,0,800)"
    # @example  Generate a DTMF string
    #   gentones "0800500005"
    # @see http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_gentones
    def gentones tgml, &b 
      execute_app "gentones", tgml, &b
    end

    # Hang up current channel
    # @example
    #   hangup
    # @example Hang up with a reason
    #   hangup "USER_BUSY"
    # @see http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_hangup
    def hangup cause="", &b
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
    def play_and_get_digits file, invalid_file, args={}, &b
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
    def playback file, &b
      execute_app "playback", file, &b
    end

    # Pre-answer establishes early media but does not answer.
    # @example
    #   pre_anser
    # @see http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_pre_answer
    def pre_answer &b
      execute_app "pre_answer", &b
    end

    # @see http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_read
    def read file, args={}, &b
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
    def record path, params={}, &b
      args = [path, params[:limit]].compact.join(" ")
      execute_app "record", args, &b
    end

    # Redirect a channel to another endpoint. You must take care to not
    # redirect incompatible channels, as that wont have the desired effect.
    # I.e. if you redirect to a SIP URI, it should be a SIP channel.
    #
    # #{redirect} can only be used on non-established calls, i.e. calls that
    # has not been answered with the #{answer} application yet. If the call has
    # been answered, use #{deflect} instead.
    # @example
    #   redirect "sip:freddie@hubbard.org"
    # @see #{deflect}
    # @see http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_redirect
    def redirect uri, &b
      execute_app "redirect", uri, &b
    end

    # Send SIP session respond code.
    # @example Send 403 Forbidden
    #   respond 403
    # @see http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_respond
    def respond code, &b
      execute_app "respond", code.to_s, &b
    end

    # Sets a channel variable.
    # @example
    #   set "some_var", "some value"
    # @see http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_set
    def set variable, value, &b
      execute_app "set", "#{variable}=#{value}", &b
    end

    # Transfers the current channel to a new context.
    # @example
    #   transfer "new_context"
    # @see http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_transfer
    def transfer context, &b
      execute_app "transfer", context, &b
    end

    # Unbinds a previously bound key with bind_meta_app
    # @example
    #   unbind_meta_app 3
    # @see http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_unbind_meta_app
    def unbind_meta_app key, &b
      execute_app "unbind_meta_app", key.to_s, &b
    end

    # Unset a channel variable.
    # @example
    #   unset "foo"
    # @see http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_unset
    def unset variable, &b
      execute_app "unset", variable, &b
    end
  end
end
