module Ork
  # Instead of monkey patching Kernel or trying to be clever, it's
  # best to confine all the helper methods in a Utils module.
  module Utils

    # Used by: `attribute`, `reference`, `collection`.
    #
    # Employed as a solution to avoid `NameError` problems when trying
    # to load models referring to other models not yet loaded.
    #
    # Example:
    #
    #   class Comment
    #     include Ork::Document
    #
    #     reference :user, User # NameError undefined constant User.
    #   end
    #
    #   Instead of relying on some clever `const_missing` hack, we can
    #   simply use a Symbol.
    #
    #   class Comment
    #     include Ork::Document
    #
    #     reference :user, :User
    #   end
    #
    def self.const(context, name)
      case name
      when Symbol then context.const_get(name)
      when String then context.const_get(name.to_sym)
      else name
      end
    end
  end
end
