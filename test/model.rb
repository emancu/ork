# encoding: utf-8
require_relative 'helper'

class Event
  include Ork::Model

  attribute :name
  attribute :location

  unique :name
  index :location
end

Protest.describe 'Ork::Model' do
  context 'Definition' do
    test 'have an attributes list' do
      assert_equal [:name, :location], Event.attributes
    end

    test 'have a uniques list' do
      assert_equal [:name], Event.uniques
    end

    test 'have an indices list' do
      assert_equal [:location], Event.indices
    end

    test 'model owns a bucket name by default' do
      assert_equal 'event', Event.bucket_name
    end

    test 'generate accessors for attributes' do
      event = Event.new

      assert event.respond_to? :name
      assert event.respond_to? :name=
      assert event.respond_to? :location
      assert event.respond_to? :location=
    end

    test 'cast to different types' do
      pending 'Define how to cast objects'
    end

    test 'model can change bucket name' do
      Event.bucket_name= 'other_bucket_for_event'
      assert_equal 'other_bucket_for_event', Event.bucket_name
    end

    test 'there is a Riak::Bucket corresponding to the model' do
      assert_equal Riak::Bucket, Event.bucket.class
    end
  end

  context 'Instance' do
    setup do
      @event = Event.new(name: 'Ruby')
    end

    test 'determine if it is a new instance or it was saved' do
      assert @event.new?
      @event.save
      assert !@event.new?
    end

    test 'assign attributes from the hash' do
      assert_equal 'Ruby', @event.name
    end

    test 'inspect a new object shows the class, attributes with id nil' do
      assert_equal '#<Event:nil {:name=>"Ruby"}>', @event.inspect
    end

    test 'inspect a saved object shows the class, attributes with id nil' do
      @event.save
      assert_equal '#<Event:' + @event.id + ' {:name=>"Ruby"}>', @event.inspect
    end

    test 'assign an ID and save the object' do
      event = Event.create(name: 'Ruby')

      assert !event.new?
      assert !event.id.nil?
    end

    test 'update and save the attributes in UTF8' do
      @event.update(name: '32° Kisei-sen')
      assert_equal '32° Kisei-sen', Event[@event.id].name
    end

    test 'update_attributes changes attributes but does not save the object' do
      assert @event.new?
      assert_equal 'Ruby', @event.name

      @event.update_attributes(name: 'Emerald', location: 4)

      assert @event.new?
      assert_equal 'Emerald', @event.name
      assert_equal 4, @event.location
    end

    context 'Deletion' do
      test 'freeze the object' do
        assert !@event.frozen?
        @event.delete
        assert @event.frozen?
      end

      test 'delete the object from the bucket' do
        @event.save
        assert Event.bucket.exist?(@event.id)
        @event.delete
        assert !Event.bucket.exist?(@event.id)
      end
    end
  end

  context "Equality" do
    setup do
      @event = Event.new(name: 'Ruby')
      @other = Event.new(name: 'Emerald')
    end

    test 'different types' do
      assert @event != 'Not an event'
    end

    test 'saved instances with different ids' do
      @event.save
      @other.save

      assert @event != @other
    end

    test 'unsaved intances' do
      pending 'Define how equality will be'
    end
  end
end
