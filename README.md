# Ork
[![Gem Version](https://badge.fury.io/rb/ork.svg)](http://badge.fury.io/rb/ork)
[![Build Status](https://travis-ci.org/emancu/ork.svg)](https://travis-ci.org/emancu/ork)
[![Code Climate](https://codeclimate.com/github/emancu/ork/badges/gpa.svg)](https://codeclimate.com/github/emancu/ork)
[![Coverage Status](https://coveralls.io/repos/emancu/ork/badge.svg)](https://coveralls.io/r/emancu/ork)
[![Dependency Status](https://gemnasium.com/emancu/ork.svg)](https://gemnasium.com/emancu/ork)

Ork is a small Ruby modeling layer for **Riak** database, inspired by [Ohm](http://ohm.keyvalue.org).

![Ork](http://f.cl.ly/items/2x2O0s3U0v2U0B3N313F/Ork.png)

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

  attribute :title
  attribute :rating, default: 4

  index :rating
  unique :title
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
| attributes   | `Array` Attributes declared                      | `[:title, :rating]`      |
| indices      | `Array` Indices declared                         | `[:rating]`              |
| uniques      | `Array` Unique indices declared                  | `[:title]`               |
| embedding    | `Array` Embedded attributes declared             | `[:post]`                |
| defaults     | `Hash` Defaults for attributes                   | `{:rating=>4}`           |


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
attribute :rating, default: 4
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

It's a special kind of attribute that references another models.
Internally, Ork will keep a an array of ids to the models, but you get
accessors that give you real instances.

It won't make a query to retrieve _all_ models taht `reference` the current model.
This is something that works well on _relational databases_ but is not recomended
for _document oriented databases_ like **Riak**.


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


## index

Create an index for the previously defined `attribute`.

```ruby
index :rating
```

## unique

Create a unique index for the previously defined `attribute`.

```ruby
unique :title
```


## Pagination

Pagination is a key feature introduced in _Riak 1.4_ and it is supported as well!

`Ork` will return the _enumerable_ `Ork::ResultSet` object which stores the keys and also the resulting objects.
The __keys__ are immediately loaded, but the __objects__ will be lazy loaded.

Given it uses the same API than `riak_client` let's jump into the examples.

```ruby

resultset = Post.find(:age, 19, max_results: 3)
# => #<Ork::ResultSet:{:max_results=>3} ['object_key_1', 'object_key_2', 'object_key_3']>

resultset.keys
# => ['object_key_1', 'object_key_2', 'object_key_3']

resultset.all
# => [#<Post:1 ...>, #<Post:2 ...>, #<Post:3 ...>]

##
# Advance to next page
##

resultset.has_next_page?
# => true

next_resultset = resultset.next_page
# => #<Ork::ResultSet:{:max_results=>3, :continuation=>'a_continuation_string'}
#    ['object_key_4', 'object_key_5']>

next_resultset.has_next_page?
# => false

next_resultset.next_page
# => raises Ork::NoNextPage: There is no next page

##
# Skip pages and start from a continuation
##

resultset2 = Post.find(:age, 19, max_results: 3, continuation: 'a_continuation_string')
# => #<Ork::ResultSet:{:max_results=>3, :continuation=>'a_continuation_string'}
#    ['object_key_4', 'object_key_5']>

resultset2 == resultset.next_page
# => true

```

## Validations

As you can see, there is no reference to validations in this document and I'm aware of that!
The validation logic for _nested embedded objects_ makes the code more complex than I want.
Given that I want to keep this gem as simple as I can, I decided to avoid _object validation_ logic here and promote the use of other gems.

There are good implementations for object validation like [hatch](https://github.com/tonchis/hatch) or [scrivener](https://github.com/soveran/scrivener) which they do a great job!
If you don't know them, you should take a look, but remember that you are free to use your prefered _gem_ or even your own method!

Just remember to check if an object is _valid_ __before__ you _save_ it.

# Ork vs Ripple

![Ork_vs_ripple](http://f.cl.ly/items/2L2F090T3C0i0H1C2C1P/Image%202014-04-23%20at%203.52.56%20PM.png)

# Tools

* `rekon` - A visual browser for **riak**, built as a [riak app](https://github.com/basho/rekon).
