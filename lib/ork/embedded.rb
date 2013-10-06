require_relative 'model'

module Ork
  module Embeddable

    def self.included(klass)
      klass.send(:include, Ork::Model)
      klass.extend(Ork::Model::Embedded::ClassMethods)
    end

    def embeddable?
      true
    end

    def __parent
      @attributes[self.class.__parent_key] or raise Ork::ParentMissing
    end

    def __parent=(object)
      @attributes[self.class.__parent_key] = object
    end


    # Check for equality by doing the following assertions:
    #
    # 1. That the passed model is of the same type.
    # 2. That they represent the same RObject id.
    #
    def ==(other)
      #FIXME: Define!
      other.kind_of?(model) && other.__parent == __parent
    end
    alias :eql? :==

    def new?
      __parent.new? # FIXME
    end

    # Pretty print for the model
    #
    #  Example:
    #
    #    User.new(name: 'John').inspect
    #    # => #<User {:name=>"John"}>
    def inspect
      "#<#{model} #{attributes.inspect}>"
    end

    # Delete the embedded object
    def delete
      unless new?
        __parent.embedded = nil
        __parent.save!
        @attributes.delete self.class.__parent_key
      end
      freeze
    rescue Riak::FailedRequest
      false
    end

    def save
      # FIXME: Work with validations, scrivener or hatch?
      # __parent.save if valid?
      __parent.save
    end

    def save!
      __parent.save!
    end

    protected

    # Persist the object in Riak database
    def __save__
      @attributes[:_type] = model.name

      # __check_unique_indices
      # __update_indices
      __parent.save!

      @attributes.delete :_type

      self
    end
  end
end
