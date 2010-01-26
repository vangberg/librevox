Gem::Specification.new do |s|
  s.name     = "librevox"
  s.version  = "0.2"
  s.date     = "2010-01-26"
  s.summary  = "Ruby library for interacting with FreeSWITCH."
  s.email    = "harry@vangberg.name"
  s.homepage = "http://github.com/ichverstehe/librevox"
  s.description = "EventMachine-based Ruby library for interacting with the
open source telephony platform FreeSwitch."
  s.authors  = ["Harry Vangberg"]
  s.files    = [
    "README.md", 
    "LICENSE",
    "TODO",
    "Rakefile",
		"librevox.gemspec", 
		"lib/librevox.rb",
    "lib/librevox/applications.rb",
    "lib/librevox/command_socket.rb",
    "lib/librevox/commands.rb",
    "lib/librevox/response.rb",
    "lib/librevox/listener/base.rb",
    "lib/librevox/listener/inbound.rb",
    "lib/librevox/listener/outbound.rb"
  ]
  s.test_files  = [
    "spec/helper.rb",
    "spec/librevox/listener.rb",
    "spec/librevox/spec_applications.rb",
    "spec/librevox/spec_command_socket.rb",
    "spec/librevox/spec_commands.rb",
    "spec/librevox/spec_response.rb",
    "spec/librevox/listener/spec_inbound.rb",
    "spec/librevox/listener/spec_outbound.rb"
  ]
end

