require 'rubygems'
if ARGV.include?('--localmp')
  require "/code/mongo_persist/lib/mongo_persist"
else
  require 'mongo_persist'
end
require 'haml'
require 'mongo_scope'
require 'activesupport'

%w(ext mongo_ext mongo_display proxy_coll user_collection sanity).each { |x| require File.dirname(__FILE__) + "/#{x}" }