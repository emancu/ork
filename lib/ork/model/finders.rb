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
      Ork::ResultSet.all(self)
    end
    alias :list :all

    # Find values in indexed fields.
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

    def load_key(id)
      new.send(:load!, id)
    rescue Riak::FailedRequest => e
      raise e unless e.not_found?
    end

  end
end
