module Ork::Model
  class Index

    def initialize(name, type = 'bin')
      @name, @type = name, type
    end

    # Index name in riak format
    def riak_name
      "#@name\_#@type"
    end

    # Take the attributes needed by the index.
    # It's best to normalize or encode any
    # user-supplied data before using it as an index
    def value_from(attributes)
      Set[attributes[@name]]
    end
  end
end
