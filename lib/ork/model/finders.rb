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
    def [](id)
      load_key(id) if exist?(id)
    end

    # Check if the ID exists.
    def exist?(id)
      !id.nil? && bucket.exists?(id)
    end
    alias :exists? :exist?

    # Find all documents in the Document's bucket and return them.
    #   @return [Array<Document>] all found documents in the bucket
    #
    # @Note: This operation is incredibly expensive and should not
    #   be used in production applications.
    #
    def all
      load_robjects bucket.get_many(bucket.keys)
    end
    alias :list :all

    # Find values in indexed fields.
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
    #   User.find(name: 'John').include?(u)
    #   # => true
    #
    #   User.find(name: 'Mike').include?(u)
    #   # => false
    #
    # Note: If the key was not defined, an
    # `Ork::IndexNotFound` exception is raised.
    #
    def find(by_index, value)
      raise Ork::IndexNotFound unless indices.has_key? by_index

      index = indices[by_index]
      load_robjects bucket.get_many(bucket.get_index(index.riak_name, value))
    end

    private

    def load_key(id)
      new.send(:load!, id)
    rescue Riak::FailedRequest => e
      raise e unless e.not_found?
    end

    def load_robjects(robjects)
      robjects.map do |id, robject|
        new.send(:__load_robject!, id, robject)
      end
    end

  end
end
