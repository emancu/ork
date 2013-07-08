# `ork`
[![Gem Version](https://badge.fury.io/rb/ork.png)](http://badge.fury.io/rb/ork)
[![Build Status](https://secure.travis-ci.org/eMancu/ork.png)](http://travis-ci.org/eMancu/ork)
[![Code Climate](https://codeclimate.com/github/eMancu/ork.png)](https://codeclimate.com/github/eMancu/ork)
[![Coverage Status](https://coveralls.io/repos/eMancu/ork/badge.png)](https://coveralls.io/r/eMancu/ork)
[![Dependency Status](https://gemnasium.com/eMancu/ork.png)](https://gemnasium.com/eMancu/ork)

`ork` is a small Ruby modeling layer for **Riak**, Basho's distributed database inspired by [Ohm](http://ohm.keyvalue.org).

## Dependencies

`ork` requires Ruby 1.9 or later and the `riak-client` gem to connect to **Riak**.

## Getting started

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
