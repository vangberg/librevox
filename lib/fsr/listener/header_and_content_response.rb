require 'fsr/listener'
require 'eventmachine'

module FSR
  module Listener
    # FIXME: This is quite the verbose name
    class HeaderAndContentResponse
      def self.from_raw(headers, content)
        hash_headers = headers_2_hash(headers)
        hash_content = headers_2_hash(content)
        new(:headers => hash_headers, :content => hash_content)
      end

      attr_reader :headers, :content

      # Keep backward compat with the other 2 people who use FSR
      alias body content

      def initialize(args = {})
        @headers = args[:headers] || {}
        @content = args[:content] || {}
        normalize_headers!
      end

      # Using #=~, since even NilClass resonds to that.
      def has_event_name?(name)
        content[:event_name] =~ /#{Regexp.escape(name.to_s)}/i
      end

      # Answer with empty String if not found, that makes it possible to simply
      # call #empty? on the result
      def event_name
        event_name = content[:event_name]
        event_name ? event_name.strip : ''
      end

      def normalize_headers!
        @headers.keys.each do |key|
          @headers[key] = @headers[key].to_s.strip
        end
      end

      # Ported from EventMachine and made 1.9-safe
      def self.headers_2_hash(headers)
        hash = {}
        headers.each_line do |line|
          if /\A([^\s:]+)\s*:\s*/ =~ line
            tail = $'.dup
            hash[ $1.downcase.tr('-', '_').to_sym ] = tail
          end
        end
        hash
      end
    end
  end
end
