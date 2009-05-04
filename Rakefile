require 'rake/clean'
require "rubygems"

require "lib/fsr"
GEMSPEC = Gem::Specification.new do |spec|
  spec.name = "freeswitcher"
  spec.version = FSR::VERSION
  spec.summary = 'A library for interacting with the "FreeSWITCH":http://freeswitch.org telephony platform'
  spec.authors = ["Jayson Vaughn", "Michael Fellinger", "Kevin Berry", "TJ Vanderpoel"]
  spec.email = "FreeSWITCHeR@rubyists.com"
  spec.homepage = "http://code.rubyists.com/projects/fs"
  spec.add_dependency "eventmachine"
  all_files = %x{git ls-files}.split.reject { |f| f.match(/^(?:contrib)(?:\/|$)/) }
  
  spec.files = all_files.reject { |f| f.match(/^(?:spec)(?:\/|$)/) }
  spec.test_files = all_files - spec.files
  spec.require_path = "lib"

  description = File.read("README")
  spec.description = description
  spec.rubyforge_project = "freeswitcher"
  spec.post_install_message = description
end

import(*Dir['tasks/*rake'])

task :default => :bacon
