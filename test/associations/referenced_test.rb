require_relative '../helper'

Protest.describe 'referenced' do
  class Post
    include Ork::Model
    attribute :name

    referenced :comment, :Comment
    referenced :weird_comment, :Comment, :weird_post
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
    post = Post.new

    assert post.comment.nil?
  end

  test 'defines reader method but not a writer method' do
    post = Post.new

    assert post.respond_to?(:comment)
    assert !post.respond_to?(:comment=)
  end

  should 'return the object referenced' do
    post = Post.create name: 'New'
    comment = Comment.create post: post
    post.reload

    assert_equal comment, post.comment
  end

  test 'object reference with not default key' do
    post = Post.create name: 'New'
    comment = Comment.create weird_post: post

    assert_equal comment, post.weird_comment
  end

  should 'update referenced object' do
    post = Post.create name: 'New'
    comment = Comment.create text: 'First One'

    assert post.comment.nil?

    comment.post = post
    comment.save

    assert_equal comment, post.comment
  end
end
