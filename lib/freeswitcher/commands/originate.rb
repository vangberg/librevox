
module FreeSwitcher
  module Commands
    class Originate
      attr_accessor :originator, :target, :application, :application_arguments, :caller_id_number, :caller_id_name
      attr_reader :fs_socket

      def initialize(fs_socket, args = {})
        @fs_socket = fs_socket
        @target = args[:target]
        @originator = args[:originator]
        @application = args[:application]
        @application_arguments = args[:application_arguments]
        @caller_id_number = args[:caller_id_number]
        @caller_id_name = args[:caller_id_name]
        @timeout = args[:timeout] || 15
      end

      def run(api_method = :bgapi, wait_for_media = true)
        target_opts = []
        target_opts << "ignore_early_media=true" if wait_for_media
        target_opts << "origination_timeout=#{@timeout}"
        if @originator
          orig_command = "#{api_method} originate {#{target_opts.join(',')}}#{@target} #{@originator}"
        elsif @application and @application_arguments
          orig_command = "#{api_method} originate {#{target_opts.join(',')}}#{@target} &#{@application}(#{@application_arguments})"
        else
          raise "Invalid originator or application"
        end
        Log.debug "saying #{orig_command}"
        @fs_socket.say(orig_command)
      end
    end

    register(:originate, Originate)
  end
end
