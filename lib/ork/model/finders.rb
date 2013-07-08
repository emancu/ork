module Ork::Model
  module Finders

    # Retrieve a record by ID.
    #
    # Example:
    #
    #   u = User.create
    #   u == User[u.id]
    #   # =>  true
    #
    def [](id)
      new.send(:load!, id) if exist?(id)
    rescue Riak::FailedRequest => e
      raise e unless e.not_found?
      nil
    end

    # Check if the ID exists.
    def exist?(id)
      !id.nil? && bucket.exists?(id)
    end
    alias :exists? :exist?

    # Find all documents in the Document's bucket and return them.
    # @overload list()
    #   Get all documents and return them in an array.
    #   @param [Hash] options options to be passed to the
    #     underlying {Bucket#keys} method.
    #   @return [Array<Document>] all found documents in the bucket
    #
    # @Note: This operation is incredibly expensive and should not
    #   be used in production applications.
    #
    def all
      bucket.keys.inject([]) do |acc, k|
        obj = self[k]
        obj ? acc << obj : acc
      end
    end
    alias :list :all

  end
end
