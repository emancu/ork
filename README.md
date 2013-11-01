# Ork
[![Gem Version](https://badge.fury.io/rb/ork.png)](http://badge.fury.io/rb/ork)
[![Build Status](https://secure.travis-ci.org/emancu/ork.png)](http://travis-ci.org/emancu/ork)
[![Code Climate](https://codeclimate.com/github/emancu/ork.png)](https://codeclimate.com/github/emancu/ork)
[![Coverage Status](https://coveralls.io/repos/emancu/ork/badge.png)](https://coveralls.io/r/emancu/ork)
[![Dependency Status](https://gemnasium.com/emancu/ork.png)](https://gemnasium.com/emancu/ork)

Ork is a small Ruby modeling layer for **Riak** database, inspired by [Ohm](http://ohm.keyvalue.org).

## Dependencies

`ork` requires Ruby 1.9 or later and the `riak-client` gem to connect to **Riak**.

Install dependencies using `dep` is easy as run:

    dep install

## Installation

Install [Riak](http://basho.com/riak/) with your package manager:

    $ brew install riak

Or download it from [Riak's download page](http://docs.basho.com/riak/latest/downloads/)

Once you have it installed, you can execute `riak start` and it will run on `localhost:8098` by default.

If you don't have Ork, try this:

    $ gem install ork

## Getting started

Ork helps you to focus your energy on modeling and designing the object collaborations without worry about how Riak works.
Take a look at the example below:

### Example

```ruby
class Post
  include Ork::Document

  attribute :name
  attribute :age, default: 18

  index :age
  unique :name
end

class Comment
  include Ork::Document

  attribute :text
  reference :post, :Post
end
```

It also gives you some helpful **class methods**:


| Class Method | Description                                      | Example (ruby)           |
|:-------------|:-------------------------------------------------|:-------------------------|
| bucket       | `Riak::Bucket` The bucket assigned to this class | `#<Riak::Bucket {post}>` |
| bucket_name  | `String` The bucket name                         | `"post"`                 |
| attributes   | `Array` Attributes declared                      | `[:name, :age]`          |
| indices      | `Array` Indices declared                         | `[:age]`                 |
| uniques      | `Array` Unique indices declared                  | `[:name]`                |
| embedding    | `Array` Embedded attributes declared             | `[:post]`                |
| defaults     | `Hash` Defaults for attributes                   | `{:age=>18}`             |


And for **instance methods** it defines:

| Instance Method                    | Description                                       |
|:-----------------------------------|:--------------------------------------------------|
| new?                               | `Bool` Answer if its a new instance or not.       |
| embeddable?                        | `Bool` Answer if its an embeddable object or not. |
| update(_attr_)                     | `Bool` Update model attributes and save it.       |
| update_attributes(_attr_)          | `Array` Update model attributes.                  |
| update_embedded_attributes(_attr_) | `Array` Update embedded model attributes.         |
| reload                             | `<class>` Preload all the attributes from Riak.   |
| save                               | `Bool` Persist document.                          |
| delete                             | `Bool` Delete the document from Riak.             |



# Modeling
> Embeddable objects are those with `include Ork::Embeddable` and they can not be saved
> without a parent.


Core behaviour of `Ork::Model`.

## attribute

An `attribute` is just any value that can be stored. It is composed of a `:name` and an optional `hash`.

```ruby
attribute :age, default: 18
```

#### Options

- `default: nil` set to the attribute a _value_ by default.

- `accessors: [:reader, :writer]` defines which accessors will be defined
  * `:reader` a.k.a **attr_reader**, create a method to read the value.
  * `:writer` a.k.a **attr_writer**, create a method to write the value.
  * `:question` create a question method. Perfect for **bool** attributes.


## reference

It's a special kind of attribute that references another model.
Internally, Ork will keep a pointer to the model (its ID), but you get
accessors that give you real instances. You can think of it as the model
containing the foreign key to another model.

```ruby
reference :user, :User
```

## referenced

Provides an accessor to search for _one_ model that `reference` the current model.

```ruby
referenced :comment, :Comment
```

## collection

Provides an accessor to search for _all_ models that `reference` the current model.

```ruby
collection :comments, :Comment
```

## embed
> Only accepts embeddable objects.

It's a special kind of attribute that embeds another model.
Internally, Ork will keep the object as an attribute, but you get
accessors that give you real instances.

```ruby
embed :comment, :Comment
```

## embed_collection
> Only accepts embeddable objects.

Provides an accessor for _all_ models that are `embedded` into the current model.
It also provides a method for _adding_ objects to this collection.

```ruby
embed_collection :comments, :Comment

# It provides
def add_comments(a_comment)
  # code
end
```


## embedded
> Only for embeddable objects.

Provides an accessor to the object that `embeds` the current model.

```ruby
embedded :post, :Post
```

## Tools

* `rekon` - A visual browser for **riak**, built as a [riak app](https://github.com/basho/rekon).
