module FreeSwitcher
  module Applications
    class Application
    end

    APPLICATIONS = {}
    LOAD_PATH = [File.join(FreeSwitcher::ROOT, "freeswitcher", "applications")]

    def self.register(application, obj)
      APPLICATIONS[application.to_sym] = obj

      code = "def %s(*args, &block) APPLICATIONS[%p].new(self, *args, &block) end" % [application, application]
      Applications.module_eval(code)
    end

    def self.list
      APPLICATIONS.keys
    end

    def self.load_application(application, force_reload = false)
      # If we get a path specification and it's an existing file, load it
      if File.file?(application)
        if force_reload
          return load(application)
        else
          return require(application)
        end
      end

      # If we find a file named the same as the application passed in LOAD_PATH, load it
      if application_file = LOAD_PATH.detect { |application_path| File.file?(File.join(application_path, "#{application}.rb")) }
        if force_reload
          load application_file
        else
          require application_file
        end
      else
        raise "#{application} not found in #{LOAD_PATH.join(":")}"
      end
    end

    # Load all of the applications we find in Applications::LOAD_PATH
    def self.load_all(force_reload = false)
      LOAD_PATH.each do |load_path|
        Dir[File.join(load_path, "*.rb")].each { |application_file| load_application(application_file, force_reload) }
      end
      list
    end

    def applications
      FreeSwitcher::Applications.list
    end
  end
end
