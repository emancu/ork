# Ork
[![Gem Version](https://badge.fury.io/rb/ork.png)](http://badge.fury.io/rb/ork)
[![Build Status](https://secure.travis-ci.org/eMancu/ork.png)](http://travis-ci.org/eMancu/ork)
[![Code Climate](https://codeclimate.com/github/eMancu/ork.png)](https://codeclimate.com/github/eMancu/ork)
[![Coverage Status](https://coveralls.io/repos/eMancu/ork/badge.png)](https://coveralls.io/r/eMancu/ork)
[![Dependency Status](https://gemnasium.com/eMancu/ork.png)](https://gemnasium.com/eMancu/ork)

Ork is a small Ruby modeling layer for **Riak** database, inspired by [Ohm](http://ohm.keyvalue.org).

## Dependencies

`ork` requires Ruby 1.9 or later and the `riak-client` gem to connect to **Riak**.

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
  include Ork::Model
  
  attribute :name
  attribute :age, default: 18
  
  index :age
  unique :name
end

class Comment
  include Ork::Model
  
  attribute :text
  reference :post, :Post
end
```

And it also gives you some helpful **class methods**:


| Class Method | Description | Example (ruby) |
|:-------------|:------------|:-------------|
| bucket       | `Riak::Bucket` The bucket assigned to this class | `#<Riak::Bucket {post}>`
| bucket_name  | `String` The bucket name                         | `"post"`
| attributes   | `Array` Attributes declared                      | `[:name, :age]`
| indices      | `Array` Indices declared                         | `[:age]`
| uniques      | `Array` Unique indices declared                  | `[:name]`     
| defaults     | `Hash` Defaults for attributes                   | `{:age=>18}`


## Attributes

Ork::Model provides one attribute type:

- Ork::Model.attribute attribute

And three meta types:

- Ork::Model.reference  reference
- Ork::Model.referenced referenced
- Ork::Model.collection collection

### attribute

An `attribute` is just any value that can be stored.

### reference

It's a special kind of attribute that references another model.
Internally, Ork will keep a pointer to the model (its ID), but you get
accessors that give you real instances. You can think of it as the model
containing the foreign key to another model.

### referenced

Provides an accessor to search for _one_ model that `reference` the current model.

### collection

Provides an accessor to search for _all_ models that `reference` the current model.
