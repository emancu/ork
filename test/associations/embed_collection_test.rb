require_relative '../helper'

Protest.describe 'embed_collection' do
  class Note
    include Ork::Document
    attribute :name

    embed_collection :annotations, :Annotation
  end

  class Annotation
    include Ork::Embeddable
    attribute :text

    embedded :note, :Note
  end

  setup do
    randomize_bucket_name Note
    @note = Note.new name: 'New'
  end

  test 'return an empty array when there are not embedded objects' do
    assert @note.annotations.empty?
  end

  test 'defines reader method but not a writer method' do
    assert @note.respond_to?(:annotations)
    deny   @note.respond_to?(:annotations=)
    assert @note.respond_to?(:annotations_add)
  end

  test 'add a Annotation to the collection associates the object with the parent' do
    assert @note.annotations.empty?

    annotation = Annotation.new text: 'Adding annotation'
    @note.annotations_add annotation

    assert_equal @note, annotation.__parent
  end

  test 'return the array of Annotations embedded on this Note' do
    annotation1 = Annotation.new text: 'One'
    annotation2 = Annotation.new text: 'Two'

    @note.annotations_add(annotation1)
    @note.annotations_add(annotation2)

    deny   @note.annotations.empty?
    assert @note.annotations.include?(annotation1)
    assert @note.annotations.include?(annotation2)
  end

  test 'load a Note with a collection of embedded objects' do
    annotation1 = Annotation.new text: 'One'
    annotation2 = Annotation.new text: 'Two'

    @note.annotations_add(annotation1)
    @note.annotations_add(annotation2)
    @note.save
    @note.reload

    deny   @note.annotations.empty?
    assert @note.annotations.include?(annotation1)
    assert @note.annotations.include?(annotation2)
  end
end

