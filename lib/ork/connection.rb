module Ork
  class Connection
    attr_accessor :context, :options

    def initialize(context = :main, options = {})
      @context = context
      @options = options
    end

    def reset!
      threaded[context] = nil
    end

    def start(context, options = {})
      self.context = context
      self.options = options
      self.reset!
    end

    def riak
      threaded[context] ||= Riak::Client.new(options)
    end

    def threaded
      Thread.current[:ork] ||= {}
    end
  end
end
