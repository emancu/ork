# encoding: utf-8
require_relative 'helper'

class Human
  include Ork::Model

  attribute :name
  attribute :last_name

  unique :name
  index :last_name
end

Protest.describe 'Finders' do
  setup do
    @human1 = Human.create(name: 'Tony',  last_name: 'Montana')
  end

  teardown do
    flush_db!
  end

  test 'retrieve an object by id' do
    assert_equal @human1, Human[@human1.id]
  end

  test 'return nil when the id does not belong to an object of this bucket' do
    assert_equal nil, Human['not_an_id']
  end

  test 'if exist an object with the id' do
    assert !Human.exist?(nil)
    assert !Human.exist?('not_an_id')
    assert Human.exist?(@human1.id)
  end

  test 'list all the objects' do
    human2 = Human.create(name: 'Cacho', last_name: 'Castaña')
    assert_equal 2, Human.list.size
    assert Human.list.include?(@human1)
    assert Human.list.include?(human2)
  end

end
