module Ork
  class Error < StandardError; end
  class IndexNotFound < RuntimeError; end
  class UniqueIndexViolation < RuntimeError; end

  # Document
  class NotOrkDocument < StandardError; end

  # Embedded
  class NotEmbeddable < StandardError; end
  class ParentMissing < RuntimeError; end


  class NoNextPage < Error; end
end
