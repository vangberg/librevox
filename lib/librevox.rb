require 'logger'
require 'fiber'
require 'eventmachine'
require 'librevox/listener/inbound'
require 'librevox/listener/outbound'
require 'librevox/command_socket'

module Librevox
  VERSION = "0.5"

  def self.options
    @options ||= {
      :log_file   => STDOUT,
      :log_level  => Logger::INFO
    }
  end

  def self.logger
    @logger ||= logger!
  end

  def self.logger!
    logger = Logger.new(options[:log_file])
    logger.level = options[:log_level]
    logger
  end

  # When called without a block, it will start the listener that is passed as
  # first argument:
  #   
  #   Librevox.start SomeListener
  #
  # To start multiple listeners, call with a block and use `run`:
  #
  #   Librevox.start do
  #     run SomeListener
  #     run OtherListner
  #   end
  def self.start klass=nil, args={}, &block
    logger.info "Starting Librevox"

    EM.run do
      trap("TERM") {stop}
      trap("INT") {stop}

      block_given? ? instance_eval(&block) : run(klass, args)
    end
  end

  def self.run klass, args={}
    host = args.delete(:host) || "localhost"
    port = args.delete(:port)

    if klass.ancestors.include? Librevox::Listener::Inbound
      EM.connect host, port || "8021", klass, args
    elsif klass.ancestors.include? Librevox::Listener::Outbound
      EM.start_server host, port || "8084", klass, args
    end
  end

  def self.stop
    logger.info "Terminating Librevox"
    EM.stop
  end
end
