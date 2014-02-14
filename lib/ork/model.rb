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
        if val.is_a? Array
          val.each do |object_atts|
            model = Ork::Utils.const(self.class, object_atts.delete('_type'))
            send(:"#{att}_add", model.new(object_atts))
          end
        else
          model = Ork::Utils.const(self.class, val.delete('_type'))
          send(:"#{att}=", model.new(val))
        end
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
  end
end
