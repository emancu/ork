module Ork::Model
  module ClassMethods
    attr_writer :bucket_name

    # Syntactic sugar for Model.new(atts).save
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

    def indices
      @indices ||= []
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
    #     include Ork::Model
    #
    #     attribute :name
    #   end
    #
    #   # It's the same as:
    #
    #   class User
    #     include Ork::Model
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

      define_method(name) do
        @attributes[name]
      end

      define_method(:"#{name}=") do |value|
        @attributes[name] = value
      end
    end

    # Index any method on your model. Once you index a method, you can
    # use it in `find` statements.
    def index(attribute)
      indices << attribute unless indices.include?(attribute)
    end

    # Create a unique index for any method on your model.
    #
    # Note: if there is a conflict while saving, an
    # `Ork::UniqueIndexViolation` violation is raised.
    #
    def unique(attribute)
      uniques << attribute unless uniques.include?(attribute)
    end
  end
end
