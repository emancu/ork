require_relative 'model/class_methods'
require_relative 'model/associations'

module Ork
  module Model
    attr_reader :attributes, :embedding

    def self.included(klass)
      klass.extend(Ork::Model::ClassMethods)
      klass.extend(Ork::Model::Associations)
    end

    # Initialize a model using a dictionary of attributes.
    #
    # Example:
    #
    #   u = User.new(:name => "John")
    #
    def initialize(atts = {})
      @attributes = {}
      @embedding = {}
      @_memo = {}
      update_attributes(model.defaults.merge(atts))
    end

    # Write the dictionary of key-value pairs to the model.
    #
    def update_attributes(atts)
      atts.delete('_type')
      atts.each { |att, val| send(:"#{att}=", val) }
    end

    protected

    def model
      self.class
    end
  end
end
