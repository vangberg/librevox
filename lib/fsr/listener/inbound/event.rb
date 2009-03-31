require 'fsr/listener/inbound'
module FSR
  module Listener
    module Inbound
      class Event
        def self.from(data)
          instance = new

          capture = header = {}
          body = {}
          
          data.each_line do |line|
            line.strip!

          case line
            when ''
              capture = body
            when /([a-zA-Z0-9-]+):\s*(.*)/
              #capture[$1.to_s.gsub("-", "_").downcase.strip.to_sym] = $2.strip
              capture[$1.gsub("-", "_").downcase.to_sym] = $2.strip
            end
          end
          
          instance.header.merge!(header)
          instance.body.merge!(body)
          instance
        end
        
        attr_reader :header, :body

        def initialize(header = {}, body = {})
          @header, @body = header, body
        end
        
        def [](key)
          @header.merge(@body)[key]
        end
      end
    end
  end
end
