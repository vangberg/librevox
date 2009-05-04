namespace :doc do
  desc "Generate API documentation for Autumn"
  task :api => :environment do
    FileUtils.remove_dir 'doc/api' if File.directory? 'doc/api'
    system "rdoc --main README --title 'Autumn API Documentation' -o doc/api --line-numbers --inline-source lib README"
  end
end
