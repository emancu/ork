require_relative '../model'
require_relative 'finders'

module Ork
  module Document
    attr_accessor :id

    def self.included(klass)
      klass.send(:include, Ork::Model)
      klass.extend(Ork::Model::Finders)
    end

    # Check for equality by doing the following assertions:
    #
    # 1. That the passed model is of the same type.
    # 2. That they represent the same RObject id.
    #
    def ==(other)
      other.kind_of?(model) && other.id == id
    end
    alias :eql? :==

    def new?
      !id
    end

    def embeddable?
      false
    end

    # Pretty print for the model
    #
    #  Example:
    #
    #    User.new(name: 'John').inspect
    #    # => #<User:6kS5VHNbaed9h7gFLnVg5lmO4U7 {:name=>"John"}>
    def inspect
      "#<#{model}:#{id || 'nil'} #{attributes.inspect}>"
    end

    # Update the model attributes and call save.
    #
    # Example:
    #
    #   User[1].update(:name => "John")
    #
    #   # It's the same as:
    #
    #   u = User[1]
    #   u.update_attributes(:name => "John")
    #   u.save
    #
    def update(attributes)
      update_attributes(attributes)
      save
    end

    # Persist the model attributes and update indices and unique
    # indices.
    #
    # Example:
    #
    #   class User
    #     include Ork::Document
    #
    #     attribute :name
    #   end
    #
    #   u = User.new(:name => "John").save
    #   # => #<User:6kS5VHNbaed9h7gFLnVg5lmO4U7 {:name=>"John"}>
    #
    def save
      __robject.content_type = model.content_type
      __robject.data = __persist_attributes

      __check_unique_indices
      __update_indices
      __robject.store

      @id = __robject.key

      self
    end

    # Preload all the attributes of this model from Riak.
    def reload
      new? ? self : self.load!(@id)
    end

    # Delete the model
    def delete
      __robject.delete unless new?
      freeze
    rescue Riak::FailedRequest
      false
    end

    protected

    # Overwrite attributes with the persisted attributes in Riak.
    #
    def load!(id)
      self.__robject.key = id
      __load_robject! id, @__robject.reload(force: true)
    end

    # Transform a RObject returned by Riak into a Ork::Document.
    #
    def __load_robject!(id, robject)
      @id = id
      @__robject = robject
      @attributes = {}
      @embedding = {}
      @_memo = {}

      data = @__robject.data
      embedded_data = {}

      model.embedding.each do |embedded|
        if d = data.delete(embedded.to_s)
          embedded_data[embedded] = d
        end
      end

      update_attributes data
      update_embedded_attributes embedded_data

      self
    end

    # Build the secondary indices of this object
    def __update_indices
      model.indices.values.each do |index|
        __robject.indexes[index.riak_name] = index.value_from(attributes)
      end
    end

    # Look up into Riak for repeated values on unique attributes
    def __check_unique_indices
      model.uniques.each do |uniq|
        if value = attributes[uniq]
          index = model.indices[uniq]
          records = model.bucket.get_index(index.riak_name, value)
          unless records.empty? || records == [self.id]
            raise Ork::UniqueIndexViolation, "#{uniq} is not unique"
          end
        end
      end
    end

    def __robject
      @__robject ||= model.bucket.new
    end
  end
end
