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

    # Writhe the dictionary of key-value pairs of embedded objects.
    #
    def update_embedded_attributes(atts)
      atts.each do |att, val|
        model = Ork::Utils.const(self.class, val.delete('_type'))
        send(:"#{att}=", model.new(val))
      end
    end

    protected

    def __persist_attributes
      attributes = @attributes.merge('_type' => model.name)

      model.embedding.each do |embedded|
        attributes[embedded] = self.send(embedded).__persist_attributes
      end

      attributes
    end


    def model
      self.class
    end
  end
end
