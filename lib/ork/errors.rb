module Ork
  class Error < StandardError; end
  class IndexNotFound < RuntimeError; end
  class UniqueIndexViolation < RuntimeError; end

  class NotOrkObject < StandardError; end

  # Document
  class InvalidClass < RuntimeError; end

  # Embedded
  class NotEmbeddable < StandardError; end
  class ParentMissing < RuntimeError; end


  class NoNextPage < Error; end
end
