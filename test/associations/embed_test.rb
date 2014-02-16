require_relative '../helper'

Protest.describe 'embed' do
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

  should 'return nil when there is no embedded object' do
    note = Note.new

    assert note.annotation.nil?
  end

  should 'raise an exception when embeds an object that is not embeddable' do
    assert_raise(Ork::NotEmbeddable) do
      Note.new.annotation = Note.new
    end
  end

  should 'return the attributes of embedded object' do
    note = Note.new name: 'New'
    note.annotation = Annotation.new text: 'An annotation'

    assert_equal "An annotation", note.embedding[:annotation][:text]
    assert_equal note, note.embedding[:annotation][:note]
  end

  should 'persist and retrieve the embedded object' do
    annotation = Annotation.new text: 'Persisted annotation'
    note = Note.create name: 'New', annotation: annotation

    note.reload
    annotation = note.annotation

    assert_equal Annotation, annotation.class
    assert_equal 'Persisted annotation', annotation.text
  end
end
