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

  should 'return nil when there is no embedded object' do
    note = Note.new

    assert note.annotation.nil?
  end

  should 'raise an exception if the parent is missing' do
    assert_raise(Ork::ParentMissing) do
      Annotation.new.__parent
    end
  end

  should 'raise an exception when embeds an object that is not embeddable' do
    assert_raise(Ork::NotAnEmbeddableObject) do
      Note.new.annotation = Post.new
    end
  end

  should 'return the parent object' do
    note = Note.new name: 'New'
    note.annotation = Annotation.new text: 'An annotation1'

    assert_equal note, note.annotation.__parent
  end

  should 'return the embedded object' do
    note = Note.new name: 'New'
    annotation = Annotation.new text: 'An annotation2', note: note

    assert_equal note, annotation.__parent
  end
end

