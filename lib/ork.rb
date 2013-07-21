require 'ork/connection'
require 'ork/model'
require 'ork/utils'
require 'ork/errors'
require "riak"

module Ork

  def self.conn
    @conn ||= Ork::Connection.new
  end

  # Stores the connection options for the Riak instance.
  #
  # Examples:
  #
  #   Ork.connect(:http_port => 6380, :pb_port => 15000)
  #
  # All of the options are simply passed on to `Riak::Client.new`.
  #
  def self.connect(context = :main, options = {})
    conn.start(context, options)
  end

  # Use this if you want to do quick ad hoc riak commands against the
  # defined Ork connection.
  #
  # Examples:
  #
  #   Ork.riak.buckets
  #   Ork.riak.bucket('foo').keys
  #
  def self.riak
    conn.riak
  end
end
