#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'rake'

desc 'Run all specs'
task :spec => :setup do
  require 'open3'

  specs = Dir['spec/fsr/**/*.rb']
  # specs.delete_if{|f| f =~ /cache\/common\.rb/ }

  some_failed = false
  total = specs.size
  len = specs.sort.last.size
  left_format = "%4d/%d: %-#{len + 12}s"
  red, green = "\e[31m%s\e[0m", "\e[32m%s\e[0m"
  matcher = /(\d+) specifications \((\d+) requirements\), (\d+) failures, (\d+) errors/
  tt = ta = tf = te = 0

  specs.each_with_index do |spec, idx|
    print(left_format % [idx + 1, total, spec])
    unless RUBY_PLATFORM.include?("mswin32")
      Open3.popen3("#{RUBY} -rubygems #{spec}") do |sin, sout, serr|
        out = sout.read
        err = serr.read

        all = out.match(matcher).captures.map{|c| c.to_i }
        tests, assertions, failures, errors = all
        tt += tests; ta += assertions; tf += failures; te += errors
  
        if tests == 0 || failures + errors > 0
          some_failed = true
          puts((red % "%5d tests, %d assertions, %d failures, %d errors") % all)
          puts "", out, err, ""
        else
          puts((green % "%5d passed") % tests)
        end
      end 
    else
      out = %x{#{RUBY} -rubygems #{spec}}
      error = ""
      all = out.match(matcher).captures.map{|c| c.to_i }
      tests, assertions, failures, errors = all
      tt += tests; ta += assertions; tf += failures; te += errors
  
      if tests == 0 || failures + errors > 0
        some_failed = true
        puts((red % "%5d tests, %d assertions, %d failures, %d errors") % all)
        puts "", out, err, ""
      else
        puts((green % "%5d passed") % tests)
      end
    end
  end

  puts "#{tt} specifications, (#{ta} requirements), #{tf} failures, #{te} errors"
  exit 1 if some_failed
end
