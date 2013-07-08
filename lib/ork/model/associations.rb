module Ork::Model
  module Associations
    # A macro for defining an attribute, an index, and an accessor
    # for a given model.
    #
    # Example:
    #
    #   class Post
    #     include Ork::Model
    #
    #     reference :user, :User
    #   end
    #
    #   # It's the same as:
    #
    #   class Post
    #     include Ork::Model
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

      index reader

      define_method(reader) do
        @attributes[reader]
      end

      define_method(writer) do |value|
        @_memo.delete(name)
        @attributes[reader] = value
      end

      define_method(:"#{name}=") do |value|
        @_memo.delete(name)
        send(writer, value ? value.id : nil)
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
    #     include Ork::Model
    #
    #     reference :user, :User
    #   end
    #
    #   class User
    #     include Ork::Model
    #
    #     referenced :post, :Post
    #   end
    #
    #   # is the same as
    #
    #   class User
    #     include Ork::Model
    #
    #     def post
    #       Post.find(:user_id => self.id)
    #     end
    #   end
    #
    def referenced(name, model, reference = to_reference)
      define_method name do
        model = Ork::Utils.const(self.class, model)
        model.find(:"#{reference}_id" => id).first
      end
    end

    # A macro for defining a method which basically does a find.
    #
    # Example:
    #   class Post
    #     include Ork::Model
    #
    #     reference :user, :User
    #   end
    #
    #   class User
    #     include Ork::Model
    #
    #     collection :posts, :Post
    #   end
    #
    #   # is the same as
    #
    #   class User
    #     include Ork::Model
    #
    #     def posts
    #       Post.find(:user_id => self.id)
    #     end
    #   end
    #
    def collection(name, model, reference = to_reference)
      define_method name do
        model = Ork::Utils.const(self.class, model)
        model.find(:"#{reference}_id" => id)
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
