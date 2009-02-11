unless ENV["REAL_HOME"].nil?
  if File.directory?(ENV["REAL_HOME"]) && File.exists?(home_rcfile = File.join(ENV["REAL_HOME"], ".irbrc"))
    load home_rcfile
  end
end

require "rubygems"
require "ride"
if ENV['RIDE_DEBUG']
  require "std_err_hooks"
end
