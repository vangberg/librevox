require "pathname"
require Pathname.new(__FILE__).dirname + "start_common"
Ramaze.start :adapter => :webrick, :port => 7000, :load_engines => [:Haml, :Erubis, :Ezamar]
