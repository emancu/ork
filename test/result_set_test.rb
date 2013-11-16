require_relative 'helper'

Protest.describe 'ResultSet' do
  class Post
    include Ork::Document
    attribute :name

    index :name
  end

  setup do
    randomize_bucket_name Post
    @post1 = Post.create name: 'Post 1'
    @post2 = Post.create name: 'Post 2'
  end

  context '*all*' do
    setup do
      @all = Ork::ResultSet.all(Post)
    end

    test 'index and query are nil' do
      assert_equal nil, @all.instance_variable_get(:@index)
      assert_equal nil, @all.instance_variable_get(:@query)
    end

    test 'model, bucket are not nil' do
      assert_equal Post, @all.instance_variable_get(:@model)
      assert_equal Post.bucket, @all.instance_variable_get(:@bucket)
    end

    test 'it has the keys set but not the loaded objects' do
      key1, key2 = Post.bucket.keys
      assert @all.instance_variable_get(:@keys).include? key1
      assert @all.instance_variable_get(:@keys).include? key2
      assert_equal nil, @all.instance_variable_get(:@all)
    end

    test 'it is not paginated' do
      deny @all.has_next_page?
    end

    test 'it returns all the objects' do
      assert_equal 2, @all.size
      assert @all.include? @post1
      assert @all.include? @post2
    end
  end

  test 'it raises an exception when call next_page if does not have next page' do
    resultset = Ork::ResultSet.all(Post)

    deny resultset.has_next_page?
    assert_raise Ork::NoNextPage do
      resultset.next_page
    end
  end

  context '*new*' do
    setup do
      @post3 = Post.create name: 'Post 1'

      @index = Post.indices[:name]
      @resultset = Ork::ResultSet.new(Post, @index, 'Post 1')
    end

    test 'the keys are not loaded' do
      assert_equal nil, @resultset.instance_variable_get(:@keys)
      assert_equal nil, @resultset.instance_variable_get(:@all)
    end

    test ':size, :count :length will not load the robjects' do
      assert_equal 2, @resultset.size
      assert_equal 2, @resultset.length
      assert_equal 2, @resultset.count

      assert @resultset.instance_variable_get(:@keys).include? @post1.id
      assert @resultset.instance_variable_get(:@keys).include? @post3.id
      assert_equal nil, @resultset.instance_variable_get(:@all)
    end

    test 'can be iterable and iterates over the objects' do
      assert @resultset.respond_to?(:each)

      @resultset.each{|post| assert_equal Post, post.class}
    end

    test 'it acts like an array' do
      deny @resultset.empty?
      assert_equal Post, @resultset.first.class
      assert_equal Post, @resultset.last.class
      assert @resultset.include? @post1
      assert @resultset.include? @post3
    end

    test 'it shows the options and keys when objects are not loaded' do
      @resultset = Ork::ResultSet.new(Post, @index, 'Post 2', max_results: 5)
      expected = "#<Ork::ResultSet:{:max_results=>5} [\"#{@post2.id}\"]>"

      assert_equal expected, @resultset.inspect
    end

    test 'it shows the options and objects when are loaded' do
      @resultset = Ork::ResultSet.new(Post, @index, 'Post 2', max_results: 5)
      expected = "#<Ork::ResultSet:{:max_results=>5} [#{@post2.inspect}]>"
      @resultset.all

      assert_equal expected, @resultset.inspect
    end
  end

  context "*options*" do
    setup do
      @post3 = Post.create name: 'Post 1'
      @index = Post.indices[:name]
    end

    context ':max_results' do
      test 'it behaves like nil when its invalid' do
        resultset = Ork::ResultSet.new(Post, @index, 'Post 1', max_results: -5)

        assert_equal nil, resultset.keys
        assert_equal nil, resultset.all
      end

      test 'it returns an empty array when did not find any object' do
        resultset = Ork::ResultSet.new(Post, @index, 'Post 9', max_results: 5)

        assert_equal [], resultset.keys
        assert_equal [], resultset.all
      end

      test 'return no more than specified objects' do
        resultset = Ork::ResultSet.new(Post, @index, 'Post 1', max_results: 1)

        assert_equal 3, Post.all.size
        assert_equal 1, resultset.size
        assert resultset.has_next_page?
      end

      test 'fetch the next page and return a new resultset' do
        post4 = Post.create name: 'Post 1'
        resultset = Ork::ResultSet.new(Post, @index, 'Post 1', max_results: 2)
        next_page = resultset.next_page

        assert_equal 2, resultset.size
        assert_equal 1, next_page.size
        deny next_page.has_next_page?
      end
    end

    context ':continuation' do
      test 'it behaves like nil when its invalid' do
        resultset = Ork::ResultSet.new(Post, @index, 'Post 1', continuation: 'not_a_continuation')

        assert_equal nil, resultset.keys
        assert_equal nil, resultset.all
      end

      test 'get a specific page' do
        post4 = Post.create name: 'Post 1'
        resultset = Ork::ResultSet.new(Post, @index, 'Post 1', max_results: 2)
        continuation = resultset.keys.continuation

        last_page = Ork::ResultSet.new(Post, @index, 'Post 1', continuation: continuation)

        assert_equal resultset.next_page.keys, last_page.keys
      end
    end
  end
end
