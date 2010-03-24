$:.unshift 'lib'

require 'bacon'
require 'librevox'

class Librevox::Listener::Outbound
  def command_reply headers={}
    msg = "Content-Type: command/reply\n"
    headers.each {|key, value|
      msg << "#{key}: #{value}\n"
    }
    receive_data msg + "\n"
  end
end

module Librevox::Matchers
  module Listener
    def send_command command
      lambda {|obj|
        obj.outgoing_data.shift.should == "#{command}\n\n"
      }
    end
  end

  module Outbound
    include Listener

    def send_application app, args=nil
      lambda {|obj|
        msg = <<-EOM
sendmsg
call-command: execute
execute-app-name: #{app}
        EOM
        msg << "execute-app-arg: #{args}\n" if args
        msg << "\n"

        obj.outgoing_data.shift.should == msg
      }
    end

    def update_session session_id=nil
      if session_id
        lambda {|obj|
          obj.outgoing_data.shift.should == "api uuid_dump #{session_id}\n\n"
        }
      else
        lambda {|obj|
          obj.outgoing_data.shift.should.match /^api uuid_dump /
        }
      end
    end

    def send_nothing
      lambda {|obj| obj.outgoing_data.shift.should == nil}
    end
  end
end

Bacon.summary_on_exit
