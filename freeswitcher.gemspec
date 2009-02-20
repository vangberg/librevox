FSR_SPEC = Gem::Specification.new do |spec|
  spec.name = "FreeSWITCHeR"
  spec.version = "0.0.2"
  spec.summary = 'A library for interacting with the "FreeSWITCH":http://freeswitch.org telephony platform'
  spec.authors = ["Jayson Vaughn", "Michael Fellinger", "Kevin Berry", "TJ Vanderpoel"]
  spec.email = "FreeSWITCHeR@rubyists.com"
  spec.homepage = "http://code.rubyists.com/projects/fs"
  require "rake"

  unfiltered_files = FileList['**/*']
  spec.files = unfiltered_files.reject do |filename|
    filename.match(/^(?:spec|config|script|log)(?:\/|$)/) || File.basename(filename).match(/\.(?:gem|gemspec|swp)$/) || File.basename(filename).match(/^(?:\.|RIDE)/)
  end

  spec.test_files = ["spec"] + FileList['spec/**/*']

  spec.require_path = "lib"

  spec.description = File.read("README")
end


