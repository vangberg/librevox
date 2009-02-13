require File.join(File.dirname(__FILE__), "..", "commands") unless FreeSwitcher.const_defined?("Commands")
module FreeSwitcher::Commands
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
    end

    def run(api_method = :bgapi, wait_for_media = true)
      target_opts = wait_for_media ? "{ignore_early_media=true}" : ""
      if @originator
        orig_command = "#{api_method} originate #{target_opts}#{@target} #{@originator}"
      elsif @application and @application_arguments
        orig_command = "#{api_method} originate #{target_opts}#{@target} &#{@application}(#{@application_arguments})"
      else
        raise "Invalid originator or application"
      end
      debug "saying #{orig_command}"
      @fs_socket.say(orig_command)
    end

    def debug(message)
      $stdout.puts message
      $stdout.flush
    end
  end

  register(:originate, Originate)
end
