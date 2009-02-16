require "fsr/app"
module FSR
  module Cmd
    class Originate < Command
      attr_accessor :target, :endpoint
      attr_reader :fs_socket, :target_options

      def initialize(fs_socket = nil, args = {})
        # These are options that will precede the target address
        @target_options = args[:target_options] || {:ignore_early_media => true}
        raise "#{@target_options} must be a hash" unless @target_options.kind_of?(Hash)
        
        @fs_socket = fs_socket # This socket must support say and <<
        @target = args[:target] # The target address to call
        # The origination endpoint (can be an extension (use a string) or application)
        @endpoint = args[:endpoint] || args[:application]

        @target_options[:origination_caller_id_number] ||= args[:caller_id_number] || FSR::DEFAULT_CALLER_ID_NUMBER
        @target_options[:origination_caller_id_name] ||= args[:caller_id_name] || FSR::DEFAULT_CALLER_ID_NAME
        @target_options[:originate_timeout] ||= args[:timeout] || @target_options[:timeout] || 15
      end

      # Send the command to the event socket, using bgapi by default.
      def run(api_method = :bgapi)
        orig_command = "%s %s" % [api_method, raw]
        Log.debug "saying #{orig_command}"
        @fs_socket.say(orig_command)
      end

      # This method builds the API command to send to the freeswitch event socket
      def raw
        target_opts = @target_options.map { |k,v| "%s=%s" % [k, v] }.join(",")
        if @endpoint.kind_of?(String)
          orig_command = "originate {#{target_opts}}#{@target} #{@endpoint}"
        elsif @endpoint.kind_of?(FSR::App::Application)
          orig_command = "originate {#{target_opts}}#{@target} '&#{@endpoint.raw}'"
        else
          raise "Invalid endpoint"
        end
      end
    end

    register(:originate, Originate)
  end
end
