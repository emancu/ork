require_relative '../helper'

Protest.describe 'collection' do
  class Post
    include Ork::Model
    attribute :name

    collection :comments, :Comment
    collection :weird_comments, :Comment, :weird_post
  end

  class Comment
    include Ork::Model
    attribute :text

    reference :post, :Post
    reference :weird_post, :Post
  end

  teardown do
    flush_db!
  end

  should 'return an empty array when there are not referenced objects' do
    post = Post.new

    assert post.comments.empty?
  end

  test 'defines reader method but not a writer method' do
    post = Post.new

    assert post.respond_to?(:comments)
    assert !post.respond_to?(:comments=)
  end

  should 'return the array of Comments referencing this Post' do
    post = Post.create name: 'New'
    comment1 = Comment.create post: post, text: 'one'
    comment2 = Comment.create post: post, text: 'two'
    post.reload

    assert !post.comments.empty?
    assert post.comments.include?(comment1)
    assert post.comments.include?(comment2)
  end

  test 'object reference with not default key' do
    post = Post.create name: 'New'
    comment1 = Comment.create weird_post: post, text: 'one'
    comment2 = Comment.create weird_post: post, text: 'two'
    post.reload

    assert !post.weird_comments.empty?
    assert post.weird_comments.include?(comment1)
    assert post.weird_comments.include?(comment2)
  end

  should 'update referenced object' do
    post = Post.create name: 'New'
    comment = Comment.create text: 'First One'

    assert post.comments.empty?

    comment.post = post
    comment.save

    assert !post.comments.empty?
    assert_equal [comment], post.comments
  end
end

