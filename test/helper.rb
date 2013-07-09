$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + "/../lib"))

require 'coveralls'
Coveralls.wear!

SimpleCov.start do
  project_name "Ork"
  command_name "Protest"

  add_filter "/test/"
end

require "rubygems"
require "protest"
require "ork"
require 'riak/test_server'

Riak.disable_list_keys_warnings = true

def test_server
  $test_server ||= begin
     require 'toml'
     path = File.expand_path("../test_riak_server.toml", __FILE__)
     config = TOML.load_file(path, symbolize_keys: true)


     server = Riak::TestServer.create(root: config[:root],
                                      source: config[:source],
                                      min_port: config[:min_port])


     Ork.connect(:test, {
      http_port: server.http_port,
      pb_port:   server.pb_port
     })

     server
   rescue => e
     puts ("Can't run Ork tests without the test server.\n" +
             "Specify the location of your Riak installation in test/test_riak_server.toml\n" +
             e.inspect)
   end
end

def flush_db!
  test_server.drop
end
