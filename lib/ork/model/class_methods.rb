require_relative 'index'

module Ork::Model
  module ClassMethods
    attr_writer :bucket_name

    # Syntactic sugar for Model.new(atts).save
    #
    def create(atts = {})
      new(atts).save
    end

    def attributes
      @attributes ||= []
    end

    def bucket
      Ork.riak.bucket(bucket_name)
    end

    def bucket_name
      @bucket_name ||= self.to_s.downcase
    end

    def embedding
      @embedding ||= []
    end

    def indices
      @indices ||= {}
    end

    def uniques
      @uniques ||= []
    end

    def defaults
      @defaults ||= {}
    end

    protected

    # Declares persisted attributes.
    # All attributes are stored on the Riak hash.
    #
    # Example:
    #   class User
    #     include Ork::Document
    #
    #     attribute :name
    #   end
    #
    #   # It's the same as:
    #
    #   class User
    #     include Ork::Document
    #
    #     def name
    #       @attributes[:name]
    #     end
    #
    #     def name=(name)
    #       @attributes[:name] = name
    #     end
    #   end
    #
    def attribute(name, options = {})
      attributes << name unless attributes.include?(name)
      defaults[name] = options[:default] if options.has_key?(:default)

      if options.has_key?(:accessors)
        to_define = Array(options[:accessors]) & accessor_options
      else # Default methods
        to_define = [:reader, :writer]
      end

      to_define.each{|m| send("#{m}_for", name) }
    end

    # Index any attribute on your model. Once you index an attribute,
    # you can use it in `find` statements.
    #
    def index(name)
      indices[name] = Index.new(name) unless indices.include?(name)
    end

    # Create a 'unique index' for any method on your model.
    # Actually it creates a regular index, but it checks if
    # it's repeated just before persist the new values.
    #
    # Note: if there is a conflict while saving, an
    # `Ork::UniqueIndexViolation` violation is raised.
    #
    def unique(attribute)
      uniques << attribute unless uniques.include?(attribute)
      index(attribute)
    end

    private

    # Valid options for attribute accessor value
    #
    def accessor_options
      [:reader, :writer, :question]
    end

    # Create reader method
    #
    def reader_for(name)
      define_method(name) do
        @attributes[name]
      end
    end

    # Create writer method
    #
    def writer_for(name)
      define_method(:"#{name}=") do |value|
        @attributes[name] = value
      end
    end

    # Create question method
    #
    def question_for(name)
      define_method(:"#{name}?") do
        !!@attributes[name]
      end
    end
  end

  module Embedded
    module ClassMethods
      attr_accessor :__parent_key

      # Declares parent accessors for embedded objects and set the parent key
      #
      # Example:
      #   class Comment
      #     include Ork::Embeddable
      #
      #     embedded :post, :Post
      #   end
      #
      #   # It's the same as:
      #
      #   class Comment
      #     include Ork::Embeddable
      #
      #     def post
      #       @attributes[:post]
      #     end
      #
      #     def post=(post)
      #       @attributes[:post] = post
      #     end
      #   end
      #
      def embedded(name, model)
        @__parent_key = name

        define_method(name) do
          @attributes[name]
        end

        define_method(:"#{name}=") do |object|
          raise Ork::ParentMissing if object.nil?

          @attributes[name] = object
        end
      end
    end
  end

end
