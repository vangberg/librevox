module Librevoz
  module Applications
    def execute_app(name, args=[], params={}, &block)
      run_app(name, args, params, &block)
    end
  end
end
