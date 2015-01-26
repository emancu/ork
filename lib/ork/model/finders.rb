require_relative '../result_set'

module Ork::Model
  module Finders

    # Retrieve a record by ID.
    #
    # Example:
    #
    #   u = User.create
    #   u == User[u.id]
    #   # => true
    #
    def [](id, options = {})
      load_key(id, options) if exist?(id, options)
    end

    # Check if the ID exists.
    def exist?(id, options = {})
      opts = {}
      opts.merge!(r: options[:quorum].to_i) if options[:quorum]

      !id.nil? && bucket.exists?(id, opts)
    end
    alias :exists? :exist?

    # Find all documents of specified keys and return them
    #
    # When nil, find all documents in the Document's bucket and return them.
    #   @return Ork::ResultSet<Document> all found documents in the bucket
    #
    # @Note: This operation can be incredibly expensive and should not
    #   be used in production applications.
    #
    def all(keys = nil)
      Ork::ResultSet.all(self, keys)
    end
    alias :list :all

    # Find values in indexed fields.
    #   @return Ork::ResultSet<Document> found documents in the bucket
    #
    # options - Hash configs for pagination.
    #   :max_results  - Number
    #   :continuation - String
    #
    # Example:
    #
    #   class User
    #     include Ork::Document
    #
    #     attribute :name
    #     index :name
    #   end
    #
    #   u = User.create(name: 'John')
    #   User.find(:name, 'John', max_results: 5).include?(u)
    #   # => true
    #
    #   User.find(:name, 'Mike').include?(u)
    #   # => false
    #
    # Note: If the key was not defined, an
    # `Ork::IndexNotFound` exception is raised.
    #
    def find(by_index, value, options = {})
      raise Ork::IndexNotFound unless indices.has_key? by_index

      index = indices[by_index]
      Ork::ResultSet.new(self, index, value, options)
    end

    private

    def load_key(id, options)
      new.send(:load!, id, options.merge(force: true))
    rescue Riak::FailedRequest => e
      raise e unless e.not_found?
    end

  end
end
