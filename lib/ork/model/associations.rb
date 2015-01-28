module Ork::Model
  module Associations
    # A macro for defining an attribute, an index, and an accessor
    # for a given model.
    #
    # Example:
    #
    #   class Post
    #     include Ork::Document
    #
    #     reference :user, :User
    #   end
    #
    #   # It's the same as:
    #
    #   class Post
    #     include Ork::Document
    #
    #     attribute :user_id
    #     index :user_id
    #
    #     def user
    #       @_memo[:user] ||= User[user_id]
    #     end
    #
    #     def user=(user)
    #       self.user_id = user.id
    #       @_memo[:user] = user
    #     end
    #
    #     def user_id=(user_id)
    #       @_memo.delete(:user_id)
    #       self.user_id = user_id
    #     end
    #   end
    #
    def reference(name, model)
      reader = :"#{name}_id"
      writer = :"#{name}_id="

      attribute reader, accessors: :reader
      index reader

      define_method(writer) do |value|
        @_memo.delete(name)
        @attributes[reader] = value
      end

      define_method(:"#{name}=") do |object|
        assert_valid_class object, model

        send(writer, object ? object.id : nil)
        @_memo[name] = object
      end

      define_method(name) do
        @_memo[name] ||= begin
                           model = Ork::Utils.const(self.class, model)
                           model[send(reader)]
                         end
      end
    end

    # A macro for defining a method which basically does a find.
    #
    # Example:
    #   class Post
    #     include Ork::Document
    #
    #     reference :user, :User
    #   end
    #
    #   class User
    #     include Ork::Document
    #
    #     referenced :post, :Post
    #   end
    #
    #   # is the same as
    #
    #   class User
    #     include Ork::Document
    #
    #     def post
    #       Post.find(:user_id => self.id)
    #     end
    #   end
    #
    def referenced(name, model, reference = to_reference)
      define_method name do
        return nil if self.id.nil?
        @_memo[name] ||= begin
                           model = Ork::Utils.const(self.class, model)
                           model.find(:"#{reference}_id", self.id).first
                         end
      end
    end

    # A macro for defining a method which basically does a find.
    #
    # Example:
    #   class Post
    #     include Ork::Document
    #
    #     reference :blog, :Blog
    #   end
    #
    #   class Blog
    #     include Ork::Document
    #
    #     many :posts, :Post
    #   end
    #
    #   # is the same as
    #
    #   class Blog
    #     include Ork::Document
    #
    #     def posts
    #       Post.find(:blog_id => self.id)
    #     end
    #   end
    #
    def many(name, model, reference = to_reference)
      define_method name do
        return [] if self.id.nil?
        model = Ork::Utils.const(self.class, model)
        model.find(:"#{reference}_id", self.id)
      end
    end

    # A macro for defining a method which basically does a find.
    #
    # Example:
    #   class Post
    #     include Ork::Document
    #
    #     reference :user, :User
    #   end
    #
    #   class User
    #     include Ork::Document
    #
    #     collection :posts, :Post
    #   end
    #
    #   # is the same as
    #
    #   class User
    #     include Ork::Document
    #
    #     attribute posts_ids
    #
    #     def posts
    #       Post.all(self.posts_ids)
    #     end
    #
    #     def posts_add(post)
    #       self.posts_ids << post.id
    #     end
    #   end
    #
    def collection(name, model, reference = to_reference)
      reader = :"#{name}_ids"

      attribute reader, accessors: :reader

      define_method(:"#{name}_ids=") do |value|
        @_memo.delete(name)
        @attributes[reader] = value
      end

      define_method(name) do
        return [] if self.id.nil?
        @_memo[name] ||= begin
                           model = Ork::Utils.const(self.class, model)
                           model.all(@attributes[reader].to_a)
                         end
      end

      define_method(:"#{name}_add") do |object|
        assert_valid_class object, model

        @attributes[reader] = Array(@attributes[reader]) << object.id
        @_memo[name] << object if @_memo[name]
      end

      define_method(:"#{name}_remove") do |object|
        assert_valid_class object, model

        @_memo[name].delete(object) if @_memo[name]
        @attributes[reader].delete(object.id) and object if @attributes[reader]
      end
    end

    # A macro for defining an attribute, and the accessors
    # for a given model.
    #
    # Example:
    #
    #   class Post
    #     include Ork::Document
    #
    #     embed :author, :Author
    #   end
    #
    #   # It's the same as:
    #
    #   class Post
    #     include Ork::Document
    #
    #     def author
    #       @embedding[:author]
    #     end
    #
    #     def author=(author)
    #       @embedding[:author] = author
    #       author.__parent = self
    #     end
    #   end
    #
    def embed(name, model)
      embedding << name unless embedding.include?(name)

      define_method(name) do
        return nil unless @embedding.has_key? name
        @_memo[name] ||= begin
                           model = Ork::Utils.const(self.class, model)
                           new_embedded model, @embedding[name]
                         end
      end

      define_method(:"#{name}=") do |object|
        assert_embeddable object

        @embedding[name] = object.attributes
        object.__parent = self

        @_memo[name] = object
      end
    end

    # A macro for find embedded objects of the same type, massive assign and
    # syntactic sugar for add an object to the collection.
    #
    # Example:
    #
    #   class Post
    #     include Ork::Document
    #
    #     embed_collection :authors, :Author
    #   end
    #
    #   # It's the same as:
    #
    #   class Post
    #     include Ork::Document
    #
    #     def authors
    #       # An array of authors
    #     end
    #
    #     def authors_add(author)
    #       # Add an author to the embed collection
    #     end
    #   end
    #
    def embed_collection(name, model)
      embedding << name unless embedding.include?(name)

      define_method(name) do
        return [] unless @embedding.has_key? name

        @_memo[name] ||= begin
                           model = Ork::Utils.const(self.class, model)
                           @embedding[name].map do |atts|
                             new_embedded model, atts
                           end
                         end
      end

      define_method(:"#{name}_add") do |object|
        assert_embeddable object

        object.__parent = self
        @_memo[name] << object if @_memo[name]
        @embedding[name] = Array(@embedding[name]) << object.attributes
      end

      define_method(:"#{name}_remove") do |object|
        assert_embeddable object

        object.__parent = nil
        @_memo[name].delete(object) if @_memo[name]
        @embedding[name].delete(object.attributes) and object if @embedding[name]
      end
    end

    private

    def to_reference
      name.to_s.
        match(/^(?:.*::)*(.*)$/)[1].
        gsub(/([a-z\d])([A-Z])/, '\1_\2').
        downcase.to_sym
    end
  end
end
