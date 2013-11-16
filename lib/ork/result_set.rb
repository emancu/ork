require 'forwardable'

module Ork
  class ResultSet
    extend Forwardable
    include Enumerable

    def_delegators :keys, :size, :count, :length, :empty?
    def_delegators :all, :each, :first, :last

    def self.all(model)
      new(model, nil, nil).tap do |r|
        r.instance_variable_set(:@keys, model.bucket.keys)
      end
    end

    def initialize(model, index, query, options={})
      @model, @index, @query, @options = model, index, query, options
      @bucket = @model.bucket
    end

    def inspect
      string = "#<#{self.class}:#{@options} %s>"

      string % (@all || self.keys).inspect
    end

    # Get the array of matched keys
    def keys(&block)
      @keys ||=
        @bucket.client.backend do |b|
          b.get_index @bucket, @index.riak_name, @query, @options, &block
        end
    end

    # Get the array of objects
    def all
      return if self.keys.nil?
      @all ||= load_robjects @bucket.get_many(@keys)
    end

    # Get a new ResultSet fetch for the next page
    def next_page
      raise Ork::NoNextPage unless has_next_page?

      self.class.new(@model,
                     @index,
                     @query,
                     @options.merge(continuation: keys.continuation))
    end

    # Determine whether a SecondaryIndex fetch has a next page available
    def has_next_page?
      keys.respond_to?(:continuation) && !!keys.continuation
    end

    private

    def load_robjects(robjects)
      robjects.map do |id, robject|
        @model.new.send(:__load_robject!, id, robject)
      end
    end

  end
end
