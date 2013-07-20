module Ork
  class Error < StandardError; end
  class IndexNotFound < RuntimeError; end
  class UniqueIndexViolation < RuntimeError; end
end
