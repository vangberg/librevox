module Librevox
  # All applications should call `application` with the following parameters:
  #
  #   `name` - name of the application
  #   `args` - arguments as a string to be sent to FreeSWITCH (optional)
  #   `params` - parameters for tweaking the command (optional)
  #
  module Applications
    # Answers an incoming call or session.
    # @see http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_answer
    def answer &block
      application "answer", &block
    end

    # Make an attended transfer
    # @example
    #   att_xfer("user/davis")
    # @see http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_att_xfer
    # @todo Add support for origination_cancel_key
    def att_xfer endpoint, &block
      application "att_xfer", endpoint, &block
    end

    # Binds an application to the specified call legs.
    # @example 
    #   bind_meta_app :key          => 2,
    #                 :listen_to    => "a",
    #                 :respond_on   => "s",
    #                 :application  => "execute_extension",
    #                 :parameters   => "dx XML features"
    # @see http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_bind_meta_app
    def bind_meta_app args={}, &block
      arg_string =
        args.values_at(:key, :listen_to, :respond_on, :application).join(" ")
      arg_string += "::#{args[:parameters]}" if args[:parameters]

      application "bind_meta_app", arg_string, &block
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
    # @see http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_bridge
    def bridge *args, &block
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

      application "bridge", variables + endpoints, &block
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
    def deflect uri, &block
      application "deflect", uri, &block
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
    def export var, args={}, &block
      nolocal = args[:local] == false ? "nolocal:" : "" # ugly!!111

      application "export", "#{nolocal}#{var}", &block
    end

    # Generate TGML tones
    # @example Generate a 500ms beep at 800Hz
    #   gentones "%(500,0,800)"
    # @example  Generate a DTMF string
    #   gentones "0800500005"
    # @see http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_gentones
    def gentones tgml , &block
      application "gentones", tgml, &block
    end

    # Hang up current channel
    # @example
    #   hangup
    # @example Hang up with a reason
    #   hangup "USER_BUSY"
    # @see http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_hangup
    def hangup cause="", &block
      application "hangup", cause, &block
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
    def play_and_get_digits file, invalid_file, args={}, &block
      min         = args[:min]          || 1
      max         = args[:max]          || 2
      tries       = args[:tries]        || 3
      terminators = args[:terminators]  || "#"
      timeout     = args[:timeout]      || 5000
      variable    = args[:variable]     || "read_digits_var"
      regexp      = args[:regexp]       || "\\d+"

      args = [min, max, tries, timeout, terminators, file, invalid_file,
        variable, regexp].join " "

      params = {:variable => variable}

      application "play_and_get_digits", args, params, &block
    end

    # Plays a sound file on the current channel.
    # @example
    #   playback "/path/to/file.wav"
    # @see http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_playback
    def playback file, &block
      application "playback", file, &block
    end

    # Pre-answer establishes early media but does not answer.
    # @example
    #   pre_anser
    # @see http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_pre_answer
    def pre_answer &block
      application "pre_answer", &block
    end

    # @see http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_read
    def read file, args={}, &block
      min         = args[:min]          || 1
      max         = args[:max]          || 2
      terminators = args[:terminators]  || "#"
      timeout     = args[:timeout]      || 5000
      variable    = args[:variable]     || "read_digits_var"

      arg_string = "%s %s %s %s %s %s" % [min, max, file, variable, timeout,
        terminators]

      params = {:variable => variable}

      application "read", arg_string, params, &block
    end

    # Records a message, with an optional limit on the maximum duration of the
    # recording.
    # @example Without limit
    #   record "/path/to/new/file.wac"
    # @example With 20 second limit
    #   record "/path/to/new/file.wac", :limit => 20
    # @see http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_record
    def record path, params={}, &block
      args = [path, params[:limit]].compact.join(" ")
      application "record", args, &block
    end

    # Redirect a channel to another endpoint. You must take care to not
    # redirect incompatible channels, as that wont have the desired effect.
    # I.e. if you redirect to a SIP URI, it should be a SIP channel.
    #
    # {#redirect} can only be used on non-established calls, i.e. calls that
    # has not been answered with the {#answer} application yet. If the call has
    # been answered, use {#deflect} instead.
    # @example
    #   redirect "sip:freddie@hubbard.org"
    # @see #deflect
    # @see http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_redirect
    def redirect uri, &block
      application "redirect", uri, &block
    end

    # Send SIP session respond code.
    # @example Send 403 Forbidden
    #   respond 403
    # @see http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_respond
    def respond code, &block
      application "respond", code.to_s, &block
    end

    # Sets a channel variable.
    # @example
    #   set "some_var", "some value"
    # @see http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_set
    def set variable, value, &block
      application "set", "#{variable}=#{value}", &block
    end

    # Transfers the current channel to a new context.
    # @example
    #   transfer "new_context"
    # @see http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_transfer
    def transfer context, &block
      application "transfer", context, &block
    end

    # Unbinds a previously bound key with bind_meta_app
    # @example
    #   unbind_meta_app 3
    # @see http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_unbind_meta_app
    def unbind_meta_app key, &block
      application "unbind_meta_app", key.to_s, &block
    end

    # Unset a channel variable.
    # @example
    #   unset "foo"
    # @see http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_unset
    def unset variable, &block
      application "unset", variable, &block
    end
  end
end
