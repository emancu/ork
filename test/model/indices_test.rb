require_relative '../helper'

class Dog
  include Ork::Document

  attribute :name
  attribute :age
  attribute :tags

  index :name
  unique :age
  index :tags
end

Protest.describe 'Indices' do
  setup do
    randomize_bucket_name Dog
  end

  test 'have an indices list' do
    assert_equal [:name, :age, :tags], Dog.indices.keys
  end

  test 'have a uniques list' do
    assert_equal [:age], Dog.uniques
  end

  test 'new instance has no indices' do
    dog = Dog.new(name: 'Chono')

    assert dog.send(:__robject).indexes.empty?
  end

  test 'overwrite indices on save' do
    dog = Dog.create(name: 'Chono')
    robject = dog.send :__robject

    assert_equal Set['Chono'], robject.indexes['name_bin']

    dog.update(name: 'Athos')

    assert_equal Set['Athos'], robject.indexes['name_bin']
  end

  test 'index enumerable attributes' do
    dog = Dog.create(name: 'Chono', tags: ['guard', 'large'])
    robject = dog.send :__robject

    assert_equal Set.new(['guard', 'large']), robject.indexes['tags_bin']
  end

  test 'prevent save on UniqueIndexViolation error' do
    Dog.create(age: 14)
    dog = Dog.new(name: 'Unsaved', age: 14)
    begin
      dog.save
    rescue Ork::UniqueIndexViolation => e
    ensure
      assert_equal 1, Dog.all.size
    end

    assert dog.new?
  end

  test "doesn't raise when saving again the same object" do
    dog = Dog.create(name: 'Unique dog', age: 14)
    exception = nil

    begin
      Dog[dog.id].save
    rescue Exception => e
      exception = e
    end

    assert_equal nil, exception
  end


  context 'Errors' do
    test 'raise an error if the index is not defined' do
      assert_raise(Ork::IndexNotFound) { Dog.find(:not_an_index, 4) }
    end

    test 'raises when it already exists a unique value' do
      Dog.create(age: 21)
      assert_raise(Ork::UniqueIndexViolation) { Dog.create(age: 21) }
    end

    test 'should only contain ASCII characters'
  end

end
