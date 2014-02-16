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
    assert @note.respond_to?(:annotations_remove)
  end

  test 'raise an exception assigning an object of the wrong type' do
    assert_raise(Ork::NotEmbeddable) do
      Note.new.annotations_add Note.new
    end
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
    deny   @note.embedding[:annotations].empty?
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

  context 'remove an item of the collection' do
    setup do
      @annotation = Annotation.new text: 'foo'
      @note = Note.create name: 'Remove items'
      @note.annotations_add @annotation
    end

    test 'raise an exception removing an object of the wrong type' do
      assert_raise(Ork::NotEmbeddable) do
        Note.new.annotations_remove 'Not an annotation'
      end
    end

    it 'removes the object and the attributes' do
      @note.annotations_remove @annotation

      assert @note.annotations.empty?
      assert @note.embedding[:annotations].empty?
    end

    it 'removes itself as a parent of the object' do
      @note.annotations_remove @annotation

      assert_equal nil, @annotation.note
    end

    it 'return the object removed' do
      assert_equal @annotation, @note.annotations_remove(@annotation)
    end

    it 'return nil if the object is not present' do
      assert_equal nil, @note.annotations_remove(Annotation.new)
    end
  end
end

