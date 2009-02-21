module FSR
  module App
    class Application
      def to_s
        #puts caller.join("\n")
        from_methods = caller.select { |n| n.match(/:in\s`\w/) }.map { |s| s.split.last[1 .. -2] }
        from_methods.include?("sendmsg") ? sendmsg : raw
      end
    end

    APPLICATIONS = {}
    LOAD_PATH = [FSR::ROOT.join("fsr/app")]
    REGISTER_CODE = "def %s(*args, &block); APPLICATIONS[%p].new(*args, &block); end"

    def self.register(application, obj)
      APPLICATIONS[application.to_sym] = obj

      code = REGISTER_CODE % [application, application]
      App.module_eval(code)
    end

    def self.list
      APPLICATIONS.keys
    end

    def self.load_application(application, force_reload = false)
      exception = nil

      if Pathname(application).absolute?
        glob = application
      else
        glob = "{#{LOAD_PATH.join(',')}}/#{application}.{so,rb,bundle}"
      end

      Dir[glob].each do |file|
        begin
          return force_reload ? load(file) : require(file)
        rescue LoadError => exception
        end
      end

      raise("Couldn't find %s in %p" % [application, LOAD_PATH])
    end

    # Load all of the applications we find in App::LOAD_PATH
    def self.load_all(force_reload = false)
      glob = "{#{LOAD_PATH.join(',')}}/*.{so,rb,bundle}"

      Dir[glob].each do |file|
        force_reload ? load(file) : require(file)
      end

      list
    end

    def applications
      FSR::App.list
    end
  end
end
FSA = FSR::App
