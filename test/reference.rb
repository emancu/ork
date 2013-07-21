require_relative 'helper'

class Post
  include Ork::Model
  attribute :name

  referenced :comment, :Comment
  referenced :weird_comment, :Comment, :weird_post

  collection :comments, :Comment
  collection :weird_comments, :Comment, :weird_post
end

class Comment
  include Ork::Model
  attribute :text

  reference :post, :Post
  reference :weird_post, :Post
end

Protest.describe 'reference' do
  teardown do
    flush_db!
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

  context 'Deletion' do
    # Discuss if we want cascade all deletetion and that sort of things
  end
end

Protest.describe 'referenced' do
  teardown do
    flush_db!
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

Protest.describe 'collection' do
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

