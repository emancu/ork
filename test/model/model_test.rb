# encoding: utf-8
require_relative '../helper'
require 'mocha/api'

include(Mocha::API)

class Event
  include Ork::Document

  attribute :name
  attribute :location
end

Protest.describe 'Ork::Model' do
  context 'Definition' do
    test 'have an attributes list' do
      assert_equal [:name, :location], Event.attributes
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
      randomize_bucket_name Event

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

    test 'reload returns the same object if it was not saved' do
      assert_equal @event, @event.reload
    end

    test 'reload erease and updates all the attributes from the database' do
      @event.save
      @event.update_attributes(name: 'changed', location: 26)
      @event.reload

      assert_equal 'Ruby', @event.name
      assert_equal nil, @event.location
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

      test 'return false when something occurs' do
        exception =  Riak::HTTPFailedRequest.new(:get, 200, 401, {}, {})
        Riak::RObject.any_instance.stubs(:delete).raises(exception)
        @event.save

        assert !@event.delete
        assert !@event.frozen?

        Riak::RObject.any_instance.unstub(:delete)
      end
    end

    context 'Persistence' do
      test 'persist the type of the object' do
        event = Event.new(name: 'Ruby')

        assert event.send(:__persist_attributes).has_key? '_type'
        assert_equal 'Event', event.send(:__persist_attributes)['_type']
      end
    end
  end

  context 'Equality' do
    setup do
      randomize_bucket_name Event

      @event = Event.new(name: 'Ruby')
      @other = Event.new(name: 'Emerald')
    end

    test 'different types' do
      deny @event == 'Not an event'
    end

    test 'saved instances with different ids' do
      @event.save
      @other.save

      deny @event == @other
    end

    test 'unsaved intances are equal' do
      assert @event == @other
    end
  end

  context "Attribute's options" do
    context '*default*' do
      setup do
        Event.send(:attribute, :invited, default: 18)
      end

      test 'have a defaults hash' do
        assert_equal ({invited: 18}), Event.defaults
      end

      test 'when no default defined nil is assigned as first value' do
        assert_equal nil, Event.new.name
      end

      test 'set the default value defined' do
        assert_equal 18, Event.new.invited
      end
    end

    context '*accessors*' do
      test 'define no attribute accessor' do
        Event.send(:attribute, :private_attribute, accessors: nil)
        event = Event.new

        assert !event.respond_to?(:private_attribute)
        assert !event.respond_to?(:private_attribute=)
        assert !event.respond_to?(:private_attribute?)
      end

      test 'define all attribute accessors' do
        Event.send(:attribute, :flufo, accessors: [:reader, :writer, :question])
        event = Event.new

        assert event.respond_to?(:flufo)
        assert event.respond_to?(:flufo=)
        assert event.respond_to?(:flufo?)
      end

      test 'define one attribute accessors' do
        Event.send(:attribute, :boolean, accessors: :question)
        event = Event.new

        assert !event.respond_to?(:boolean)
        assert !event.respond_to?(:boolean=)
        assert event.respond_to?(:boolean?)
        assert !event.boolean?
      end

      test 'wrong options do not defines accessors' do
        Event.send(:attribute, :weird, accessors: Object)
        event = Event.new

        assert !event.respond_to?(:weird)
        assert !event.respond_to?(:weird=)
        assert !event.respond_to?(:weird?)
      end
    end
  end

end
