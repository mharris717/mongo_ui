# require 'rubygems'
if ARGV.include?('--localmp') || true
  require "/code/mongo_persist/lib/mongo_persist"
else
  require 'mongo_persist'
end
# require 'haml'
#require 'mongo_scope'
require "/code/mongo_scope/lib/mongo_scope"
# require 'activesupport'
require 'facets/file/write'

%w(ext my_logging mongo_ext mongo_display proxy_coll user_collection data_setup coll_data workspace field_info sanity odds).each { |x| require File.dirname(__FILE__) + "/#{x}" }