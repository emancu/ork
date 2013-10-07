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

  should 'build the parent relation when retrieve an embedded object from database' do
    annotation = Annotation.new text: 'Persisted annotation'
    note = Note.create name: 'New', annotation: annotation

    note.reload
    annotation = note.annotation

    assert_equal note, annotation.__parent
    assert_equal note, annotation.note
  end

end
