require 'spec/rake/spectask'
  desc "Verify API specs"
  Spec::Rake::SpecTask.new('spec') do |t|
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.spec_opts = [ '-cfs', '-r spec/helper' ]
  end
