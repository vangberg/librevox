require 'librevox'
 
class MyApp < Librevox::Listener::Outbound
  event :some_event do
    # React on event. Info available in `event`
  end

  def session_initiated
    answer do
      playback "/path/to/file.wav" do
        # Whenever we expect a meaningful answer from a command (basically, that means
        # `play_and_get_digits` and `read` we have to pass it a block. The return value
        # will be passed to the block argument.
        play_and_get_digits "/sounds/enter-digit.wav", "/sounds/wrong-digit.wav" do |digit|
          # Set channel variables
          set "playback_terminators", "#"

          # For apps not added to Librevox yet you can use
          #
          # `execute_app "app_name", "app arguments"`
          #
          # to execute generic Freeswitch commands as seen on 
          # http://wiki.freeswitch.org/wiki/Category:Dialplan
          execute_app "record", "/sound-recordings/user-recording-#{digit}.wav" do
            bridge "sofia/foo/bar", "sofia/foo/baz"
          end
        end
      end
    end
  end
end

Librevox.start MyApp
