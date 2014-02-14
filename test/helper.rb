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

I18n.enforce_available_locales = false
Riak.disable_list_keys_warnings = true
Protest.report_with(:progress)

def randomize_bucket_name(klass)
  klass.bucket_name= [
    'test',
    klass.to_s,
    Time.now.to_i,
    rand(36**10).to_s(36)
  ].join('-')
end

def deny(condition, message="Expected condition to be unsatisfied")
  assert !condition, message
end
