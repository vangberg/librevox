require 'bacon'
require 'librevox'

module Librevox::Test
  module Matchers
    def send_command command
      proc {|obj|
        obj.outgoing_data.shift.should == "#{command}\n\n"
      }
    end

    def send_nothing
      proc {|obj| obj.outgoing_data.shift.should == nil}
    end

    def send_application app, args=nil
      proc {|obj|
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
        proc {|obj|
          obj.outgoing_data.shift.should == "api uuid_dump #{session_id}\n\n"
        }
      else
        proc {|obj|
          obj.outgoing_data.shift.should.match /^api uuid_dump \d+/
        }
      end
    end
  end

  module ListenerHelpers
    def command_reply args={}
      args["Content-Type"] = "command/reply"
      response args
    end

    def api_response args={}
      args["Content-Type"] = "api/response"
      response args
    end

    def channel_data args={}
      api_response :body => {
        "Event-Name"  => "CHANNEL_DATA",
        "Session-Var" => "Second"
      }.merge(args)
    end

    def response args={}
      body    = args.delete :body
      headers = args

      if body.is_a? Hash
        body = body.map {|k,v| "#{k}: #{v}"}.join "\n"
      end

      headers["Content-Length"] = body.size if body
      msg = headers.map {|k, v| "#{k}: #{v}"}.join "\n"

      msg << "\n\n" + body if body

      @listener.receive_data msg + "\n\n"
    end

    def event name
      body    = "Event-Name: #{name}"
      headers = "Content-Length: #{body.size}"

      @listener.receive_data "#{headers}\n\n#{body}\n\n"
    end
  end
end

Bacon.summary_on_exit
