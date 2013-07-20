require_relative 'helper'

class Dog
  include Ork::Model

  attribute :name
  attribute :age

  index :name
  index :age
end

Protest.describe 'Indices' do
  teardown do
    flush_db!
  end

  test 'have an indices list' do
    assert_equal [:name, :age], Dog.indices.keys
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

  context 'Errors' do
    test 'raise an error if the index' do
      assert_raise(Ork::IndexNotFound) { Dog.find(:not_an_index, 4) }
    end

    test 'should only contain ASCII characters'
  end

end
