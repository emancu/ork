$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + "/../lib"))

unless File.exist?(File.expand_path("../test_riak_server.toml", __FILE__))
  puts "Specify the location of your Riak installation in test/test_riak_server.toml"
  exit(1)
end

require 'coveralls'
Coveralls.wear!

SimpleCov.start do
  project_name "Ork"
  command_name "Protest"

  add_filter "/test/"
end

require "rubygems"
require "protest"
require 'toml'
require 'riak/test_server'
require "ork"

Riak.disable_list_keys_warnings = true
Protest.report_with(:progress)

def test_server
  $server ||= begin
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
                puts "Can't run Ork tests without the test server."
                puts e.inspect
                exit(1)
              end
end

def randomize_bucket_name(klass)
  klass.bucket_name= [
    'test',
    klass.to_s,
    Time.now.to_i,
    rand(36**10).to_s(36)
  ].join('-')
end
