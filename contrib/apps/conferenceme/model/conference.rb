require "fsr"
require "fsr/command_socket"
class Conference
  def list
    require "hpricot"
    @sock ||= FSR::CommandSocket.new
    confs = Hpricot(@sock.say("api conference xml_list")["body"])
    all_conf_names = (confs/:conferences/:conference).map { |n| n[:name] }
  end

  def self.exists?(name)
    new.list.include?(name)
  end
end
