require File.join(File.dirname(__FILE__), "..", "commands") unless FreeSwitcher.const_defined?("Commands")
module FreeSwitcher::Commands

  class Originate
    def initialize(originator, target, extra = {})
      @originator = originator
      @target = target
      @extra = extra
    end

    def run(inbound_event_socket, api_method = :bgapi)
      inbound_event_socket.send("#{api_method} originate #{@target} #{@originator}")
    end
  end

  register(:originate, Originate)
end
