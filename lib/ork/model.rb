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
        @embedding[att] = val
      end
    end

    protected

    def __persist_attributes
      attributes = @attributes.merge('_type' => model.name)
      attributes.delete(model.__parent_key) if model.respond_to? :__parent_key

      model.embedding.each do |embedded|
        object = self.send(embedded)
        unless object.nil?
          attributes[embedded] = if object.is_a? Array
                                   object.map{|o| o.send :__persist_attributes}
                                 else
                                   object.__persist_attributes
                                 end
        end
      end

      attributes
    end

    def model
      self.class
    end

    def new_embedded(model, attributes)
      attributes[model.__parent_key] = self
      attributes.delete '_type'

      model.new attributes
    end

    def assert_valid_class(object, model)
      raise Ork::NotOrkObject.new(object) unless object.class.include? Ork::Document
      raise Ork::InvalidClass.new(object) if object.class.name != model.to_s
    end

    def assert_embeddable(object)
      unless object.respond_to?(:embeddable?) && object.embeddable?
        raise Ork::NotEmbeddable.new(object)
      end
    end
  end
end
