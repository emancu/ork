require_relative 'model/class_methods'
require_relative 'model/associations'
require_relative 'model/finders'
require_relative 'model/index'

module Ork
  module Model
    attr_reader :attributes, :id
    attr_writer :id

    def self.included(klass)
      klass.extend(Ork::Model::ClassMethods)
      klass.extend(Ork::Model::Associations)
      klass.extend(Ork::Model::Finders)
    end

    # Initialize a model using a dictionary of attributes.
    #
    # Example:
    #
    #   u = User.new(:name => "John")
    #
    def initialize(atts = {})
      @attributes = {}
      @_memo = {}
      update_attributes(model.defaults.merge(atts))
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

    # Write the dictionary of key-value pairs to the model.
    #
    def update_attributes(atts)
      atts.delete('_type')
      atts.each { |att, val| send(:"#{att}=", val) }
    end

    # Delete the model
    def delete
      __robject.delete unless new?
      freeze
    rescue Riak::FailedRequest
      false
    end

    # Persist the model attributes and update indices and unique
    # indices.
    #
    # If the model is not valid, nil is returned. Otherwise, the
    # persisted model is returned.
    #
    # Example:
    #
    #   class User
    #     include Ork::Model
    #
    #     attribute :name
    #
    #     def validate
    #       assert_present :name
    #     end
    #   end
    #
    #   User.new(:name => nil).save
    #   # => nil
    #
    #   u = User.new(:name => "John").save
    #   # => #<User:6kS5VHNbaed9h7gFLnVg5lmO4U7 {:name=>"John"}>
    #
    def save
      # FIXME: Work with validations, scrivener or hatch?
      # save! if valid?
      save!
    end

    # Saves the model without checking for validity. Refer to
    # `Model#save` for more details.
    def save!
      __save__
    end

    # Preload all the attributes of this model from Riak.
    def reload
      new? ? self : self.load!(@id)
    end

    protected

    # Overwrite attributes with the persisted attributes in Riak.
    def load!(id)
      @id = self.__robject.key = id
      @__robject = @__robject.reload(force: true)
      @attributes = {}
      update_attributes(@__robject.data)

      self
    end

    # Persist the object in Riak database
    def __save__
      __robject.content_type = 'application/json'
      __robject.data = @attributes.merge('_type' => model.name)

      __check_unique_indices
      __update_indices
      __robject.store

      @id = __robject.key

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

    def model
      self.class
    end
  end
end
