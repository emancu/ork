module Ork
  class Error < StandardError; end
  class IndexNotFound < RuntimeError; end
  class UniqueIndexViolation < RuntimeError; end

  class NotAnEmbeddableObject < RuntimeError; end
  class ParentMissing < RuntimeError; end

  class NoNextPage < Error; end
end
