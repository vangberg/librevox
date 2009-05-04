desc 'install all possible dependencies'
task :setup => :gem_installer do
  GemInstaller.new do
    # core
    gem 'eventmachine'

    # spec
    gem 'bacon'

    setup
  end
end
