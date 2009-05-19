require 'fsr/listener'
require 'eventmachine'

module FSR
  module Listener
    # FIXME: This is quite the verbose name
    class HeaderAndContentResponse

      # Tries to find the best subclass for the given +headers+ and +content+.
      # If the +content+ is header-like (our test is whether it contains ':'),
      # then it will create an instance of {ParsedContent}, otherwise a normal
      # {HeaderAndContentResponse} will be initialized.
      def self.from_raw(headers, content)
        hash_headers = headers_2_hash(headers)

        if content =~ /:/
          hash_content = headers_2_hash(content)
          ParsedContent.new(:headers => hash_headers, :content => hash_content)
        else
          new(:headers => hash_headers, :content => content)
        end
      end

      attr_reader :headers, :content

      # Keep backward compat with the other 2 people who use FSR
      alias body content

      def initialize(args = {})
        @headers = args[:headers] || {}
        @content = args[:content] || {}
        normalize_headers!
      end

      def normalize_headers!
        @headers.keys.each do |key|
          @headers[key] = @headers[key].to_s.strip
        end
      end

      def has_event_name?(name)
        false
      end

      def event_name
        ''
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

      class ParsedContent < self
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
      end
    end
  end
end
