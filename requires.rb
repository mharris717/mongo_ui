require 'rubygems'
if ARGV.include?('--localmp')
  require "/code/mongo_persist/lib/mongo_persist"
else
  require 'mongo_persist'
end
require 'haml'
#require 'mongo_scope'
require "/code/mongo_scope/lib/mongo_scope"
require 'activesupport'
require 'facets/file/write'

%w(ext mongo_ext mongo_display proxy_coll user_collection data_setup sanity coll_data workspace).each { |x| require File.dirname(__FILE__) + "/#{x}" }