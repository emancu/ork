require_relative '../helper'

Protest.describe 'embedded' do
  class Note
    include Ork::Document
    attribute :name

    embed :annotation, :Annotation
  end

  class Annotation
    include Ork::Embeddable
    attribute :text

    embedded :note, :Note
  end

  setup do
    randomize_bucket_name Note
  end

  should 'be embeddable' do
    assert Annotation.new.embeddable?
  end

  should 'raise an exception if the parent is missing' do
    assert_raise(Ork::ParentMissing) do
      Annotation.new.__parent
    end
  end

  should 'return the parent object' do
    note = Note.new name: 'New'
    annotation = Annotation.new text: 'An annotation1', note: note

    assert_equal note, annotation.__parent
  end

  should 'assign a parent and use the proper method' do
    note = Note.new name: 'New'
    annotation = Annotation.new text: 'An annotation1'
    annotation.__parent = note

    assert_equal note, annotation.__parent
    assert_equal note, annotation.note
  end

  should 'build the parent relation when retrieve an embedded object from database' do
    annotation = Annotation.new text: 'Persisted annotation'
    note = Note.create name: 'New', annotation: annotation

    note.reload
    annotation = note.annotation

    assert_equal note, annotation.__parent
    assert_equal note, annotation.note
  end

  context 'Persistence'do
    setup do
      @annotation = Annotation.new text: 'Annotation'
    end

    should 'not persist parent attribute' do
      Note.new name: 'A note', annotation: @annotation

      deny @annotation.note.nil?
      deny @annotation.send(:__persist_attributes).has_key? :note
    end

    should 'not respond to save methods' do
      deny @annotation.respond_to? :save
      deny @annotation.respond_to? :save!
    end
  end

  test 'inspect a new object shows the class, attributes without id' do
    annotation = Annotation.new(text: 'Ruby')
    assert_equal '#<Annotation {:text=>"Ruby"}>', annotation.inspect
  end

  context 'Equality' do
    setup do
      @annotation = Annotation.new text: 'Ruby'
    end

    test 'they are equal' do
      @annotation.__parent = Note.new name: 'Gems'
      other = @annotation.clone

      assert @annotation == other
    end

    test 'different types' do
      deny @annotation == 'Not an annotation'
    end

    test 'different attributes' do
      deny @annotation == Annotation.new(text: 'Emerald')
    end

    test 'same attributes but different parents' do
      other = Annotation.new text: 'Ruby'
      @annotation.__parent = Note.create name: 'Gems'
      other.__parent = Note.create name: 'Stones'

      deny @annotation == other
    end
  end
end
