module FreeSwitcher
  module Applications
    class Application
    end

    APPLICATIONS = {}
    LOAD_PATH = [Pathname('.'), FreeSwitcher::ROOT + "freeswitcher/applications"]
    REGISTER_CODE = "def %s(*args, &block) APPLICATIONS[%p].new(self, *args, &block) end"

    def self.register(application, obj)
      APPLICATIONS[application.to_sym] = obj

      code = REGISTER_CODE % [application, application]
      Applications.module_eval(code)
    end

    def self.list
      APPLICATIONS.keys
    end

    def self.load_application(application, force_reload = false)
      exception = nil

      glob = "{#{LOAD_PATH.join(',')}}/#{application}.{so,rb,bundle}"
      p glob

      Dir[glob].each do |file|
        begin
          return force_reload ? load(file) : require(file)
        rescue LoadError => exception
        end
      end

      raise("Couldn't find %s in %p" % application, LOAD_PATH)
    end

    # Load all of the applications we find in Applications::LOAD_PATH
    def self.load_all(force_reload = false)
      load_application('*', force_reload)
      list
    end

    def applications
      FreeSwitcher::Applications.list
    end
  end
end
