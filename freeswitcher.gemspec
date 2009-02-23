FSR_SPEC = Gem::Specification.new do |spec|
  spec.name = "FreeSWITCHeR"
  spec.version = "0.0.4"
  spec.summary = 'A library for interacting with the "FreeSWITCH":http://freeswitch.org telephony platform'
  spec.authors = ["Jayson Vaughn", "Michael Fellinger", "Kevin Berry", "TJ Vanderpoel"]
  spec.email = "FreeSWITCHeR@rubyists.com"
  spec.homepage = "http://code.rubyists.com/projects/fs"

  spec.files = ["License.txt", "README", "Rakefile", "bin", "bin/freeswitcher", "bin/oes_demo.rb", "contrib", "contrib/fsr_ride_template.erb", "lib", "lib/fsr", "lib/fsr/app", "lib/fsr/app/bridge.rb", "lib/fsr/app/conference.rb", "lib/fsr/app/fifo.rb", "lib/fsr/app.rb", "lib/fsr/cmd", "lib/fsr/cmd/originate.rb", "lib/fsr/cmd/sofia", "lib/fsr/cmd/sofia/profile.rb", "lib/fsr/cmd/sofia/status.rb", "lib/fsr/cmd/sofia.rb", "lib/fsr/cmd.rb", "lib/fsr/command_socket.rb", "lib/fsr/database", "lib/fsr/database/call_limit.rb", "lib/fsr/database/core.rb", "lib/fsr/database/sofia_reg_external.rb", "lib/fsr/database/sofia_reg_internal.rb", "lib/fsr/database/voicemail_default.rb", "lib/fsr/database.rb", "lib/fsr/event.rb", "lib/fsr/event_socket.rb", "lib/fsr/fake_socket.rb", "lib/fsr/listener", "lib/fsr/listener/inbound.rb", "lib/fsr/listener/outbound.rb", "lib/fsr/listener.rb", "lib/fsr.rb", "oes_demo.rb", "tasks", "tasks/package.rake", "tasks/spec.rake"]
  spec.test_files = ["spec", "spec/fsr", "spec/fsr/app", "spec/fsr/app/bridge.rb", "spec/fsr/app/conference.rb", "spec/fsr/app/fifo.rb", "spec/fsr/app.rb", "spec/fsr/cmd", "spec/fsr/cmd/originate.rb", "spec/fsr/cmd/sofia", "spec/fsr/cmd/sofia/profile.rb", "spec/fsr/cmd/sofia.rb", "spec/fsr/cmd.rb", "spec/fsr/listener", "spec/fsr/listener/outbound.rb", "spec/fsr/listener.rb", "spec/fsr/loading.rb", "spec/helper.rb"]
  spec.require_path = "lib"

  spec.description = %q{=========================================================
FreeSWITCHeR
Copyright (c) 2009 The Rubyists (Jayson Vaughn, Tj Vanderpoel, Michael Fellinger, Kevin Berry) 
Distributed under the terms of the MIT License.
==========================================================

About
-----
*** STILL UNDER HEAVY DEVELOPMENT ***

A ruby library for interacting with the "FreeSWITCH" (http://www.freeswitch.org) opensource telephony platform

*** STILL UNDER HEAVY DEVELOPMENT ***

Requirements
------------
- ruby (>= 1.8)
- eventmachine (If you wish to use Outbound and Inbound listener)

Usage
-----

Example of originating a new call in 'irb' using FSR::CommandSocket#originate:

  irb(main):001:0> require 'fsr'
  => true

  irb(main):002:0> FSR.load_all_commands
  => [:sofia, :originate]

  irb(main):003:0> sock = FSR::CommandSocket.new
  => #<FSR::CommandSocket:0xb7a89104 @server="127.0.0.1", @socket=#<TCPSocket:0xb7a8908c>, @port="8021", @auth="ClueCon">

  irb(main):007:0> sock.originate(:target => 'sofia/gateway/carlos/8179395222', :endpoint => FSR::App::Bridge.new("user/bougyman")).run
  => {"Job-UUID"=>"732075a4-7dd5-4258-b124-6284a82a5ae7", "body"=>"", "Content-Type"=>"command/reply", "Reply-Text"=>"+OK Job-UUID: 732075a4-7dd5-4258-b124-6284a82a5ae7"}


Example of creating an Outbound Eventsocket listener:

    #!/usr/bin/env ruby

    require 'rubygems'
    require 'eventmachine'
    require 'fsr'
    require "fsr/listener/outbound"

    module OesDemo
      include FSR::Listener::Outbound
      def session_initiated(session)
        bridge "user/bougyman"
      end
    end

    EM.run do
      port = 1888
      host = "127.0.0.1"
      EventMachine::start_server(host, port, OesDemo)
      FSR::Log.debug "* FreeSWITCHeR OES Listener on #{host}:#{port}"
    end

Support
-------
Home page at http://code.rubyists.com/projects/fs
#rubyists on FreeNode
}
end


