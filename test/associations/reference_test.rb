require_relative '../helper'

Protest.describe 'reference' do
  class Post
    include Ork::Model
    attribute :name
  end

  class Comment
    include Ork::Model
    attribute :text

    reference :post, :Post
    reference :weird_post, :Post
  end

  setup do
    randomize_bucket_name Post
    randomize_bucket_name Comment
  end

  should 'return nil when there is no reference object' do
    comment = Comment.new

    assert comment.post.nil?
  end

  should 'raise an exception assigning an object of the wrong type' do
    pending 'Not sure to support this'
    assert_raise(Error) do
      Comment.new post: 'Not a post'
    end
  end

  should 'return the object referenced' do
    post = Post.create name: 'New'
    comment = Comment.new post: post

    assert_equal post, comment.post
    assert_equal post.id, comment.post_id
  end

  test 'object reference with not default key' do
    post = Post.create name: 'New'
    comment = Comment.new weird_post: post

    assert_equal post, comment.weird_post
    assert_equal post.id, comment.weird_post_id
  end

  should 'update reference to an object given the id or object' do
    post = Post.create name: 'New'
    comment = Comment.new

    assert comment.post.nil?
    assert comment.post_id.nil?

    comment.post = post

    assert_equal post, comment.post
    assert_equal post.id, comment.post_id

    post = Post.create name: 'Other'
    comment.post_id = post.id

    assert_equal post, comment.post
    assert_equal post.id, comment.post_id
  end
end
