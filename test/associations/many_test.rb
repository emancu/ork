require_relative '../helper'

Protest.describe 'many' do
  class Blog
    include Ork::Document
    attribute :name

    many :posts, :Post
    many :weird_posts, :Post, :weird_blog
  end

  class Post
    include Ork::Document
    attribute :title

    reference :blog, :Blog
    reference :weird_blog, :Blog
  end

  setup do
    randomize_bucket_name Blog
    randomize_bucket_name Post
  end

  should 'return an empty list when there is no reference object' do
    blog = Blog.new

    assert blog.posts.empty?
  end

  test 'defines reader method but not a writer method' do
    blog = Blog.new

    assert blog.respond_to?(:posts)
    assert !blog.respond_to?(:posts=)
  end

  should 'return the objects referenced' do
    blog = Blog.create name: 'New'
    post = Post.create blog: blog
    blog.reload

    assert blog.posts.include?(post)
  end

  test 'object reference with not default key' do
    blog = Blog.create name: 'New'
    post = Post.create weird_blog: blog

    assert blog.weird_posts.include?(post)
  end

  should 'update referenced object' do
    blog = Blog.create name: 'New'
    post = Post.create title: 'First One'

    assert blog.posts.empty?

    post.blog = blog
    post.save

    assert blog.posts.include?(post)
  end
end
