
require 'rake'
require "lib/fsr"
namespace :pkg do
  desc 'Build the gemspec'
  task :build_gemspec do
    require "erb"
    unfiltered_files = Dir['**/*']
    spec_files = unfiltered_files.reject do |filename|
      filename.match(/^(?:spec|config|script|log)(?:\/|$)/) || File.basename(filename).match(/\.(?:gem|gemspec|swp)$/) || File.basename(filename).match(/^(?:\.|RIDE)/)
    end.inspect

    spec_test_files = (["spec"] + Dir['spec/**/*']).inspect
    spec_template = ERB.new(File.read("freeswitcher.gemspec.erb"))
    version = FSR::VERSION
    description = File.read("README")
    File.open("freeswitcher.gemspec", "w+") { |specfile| specfile.puts spec_template.result(binding) }

  end

  desc 'Make the gem'
  task :gem => :build_gemspec do
    output = %x{gem build freeswitcher.gemspec}
    raise "Package did not build - #{output}" unless File.exists?("FreeSWITCHeR-#{FSR::VERSION}.gem")
    puts output
  end

end

