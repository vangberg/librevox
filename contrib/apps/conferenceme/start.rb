require "pathname"
require Pathname(__FILE__).dirname + "start_common"

Ramaze.start :load_engines => [:Haml, :Erubis]
