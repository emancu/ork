module Ork
  class Error < StandardError; end
  class IndexNotFound < RuntimeError; end
  class UniqueIndexViolation < RuntimeError; end

  # Document
  class InvalidClass < RuntimeError; end

  # Embedded
  class NotAnEmbeddableObject < RuntimeError; end
  class ParentMissing < RuntimeError; end


  class NoNextPage < Error; end
end
