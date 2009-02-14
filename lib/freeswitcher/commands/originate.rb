
module FreeSwitcher
  module Commands
    class Originate
      attr_accessor :originator, :target, :application, :application_arguments, :caller_id_number, :caller_id_name
      attr_reader :fs_socket

      def initialize(fs_socket, args = {})
        # These are options that will precede the target address
        @target_options = args[:target_options] || {:ignore_early_media => true}
        raise "#{@target_options} must be a hash" unless @target_options.kind_of?(Hash)
        
        @fs_socket = fs_socket # This socket must support say and <<
        @target = args[:target] # The target address to call
        # The origination extension
        @originator = args[:originator]

        # or application to attach the target caller to, and arguments for the application
        @application = args[:application]
        @application_arguments = args[:application_arguments]
        # These are options that will precede the application as modifiers
        @application_options = args[:application_options] || {}
        raise "#{@target_options} must be a hash" unless @target_options.kind_of?(Hash)

        @caller_id_number = args[:caller_id_number] || FreeSwitcher::DEFAULT_CALLER_ID_NAME
        @caller_id_name = args[:caller_id_name] || FreeSwitcher::DEFAULT_CALLER_ID_NUMBER
        @wait_for_media = 
        @timeout = args[:timeout] || 15
      end

      def run(api_method = :bgapi, wait_for_media = true)
        orig_command = command_text
        Log.debug "saying #{orig_command}"
        @fs_socket.say(orig_command)
      end
    end

    def command_text
      target_opts = @target_options.map { |k,v| "#{k}=#{v}" }
      if @originator
        orig_command = "originate {#{target_opts.join(',')}}#{@target} #{@originator}"
      elsif @application and @application_arguments
        orig_command = "originate {#{target_opts.join(',')}}#{@target} &#{@application}(#{@application_arguments})"
      else
        raise "Invalid originator or application"
      end
    end

    register(:originate, Originate)
  end
end
