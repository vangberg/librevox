require 'librevoz/listener/inbound'
require 'librevoz/listener/outbound'

module Librevoz
  # When called without a block, it will start the listener that is passed as
  # first argument:
  #   
  #   Librevoz.start SomeListener
  #
  # To start multiple listeners, call with a block and use `run`:
  #
  #   Librevoz.start do
  #     run SomeListener
  #     run OtherListner
  #   end
  def self.start(klass=nil, args={}, &block)
    EM.run {
      block_given? ? instance_eval(&block) : run(klass, args)
    }
  end

  def self.run(klass, args={})
    host = args.delete(:host) || "localhost"
    port = args.delete(:port)

    if klass.ancestors.include? Librevoz::Listener::Inbound
      port ||= "8021"
      EM.connect host, port, klass, args
    elsif klass.ancestors.include? Librevoz::Listener::Outbound
      port ||= "8084"
      EM.start_server host, port, klass, args
    end
  end
end
