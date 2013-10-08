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
    # 2. That they have the same attributes.
    #
    # How it was developed, 2 implies 1.
    #
    def ==(other)
      other.kind_of?(model) &&
        __persist_attributes == other.__persist_attributes &&
        other.attributes[model.__parent_key] == @attributes[model.__parent_key]
    end
    alias :eql? :==

    # Pretty print for the model
    #
    #  Example:
    #
    #    User.new(name: 'John').inspect
    #    # => #<User {:name=>"John"}>
    #
    def inspect
      "#<#{model} #{attributes.inspect}>"
    end
  end
end
