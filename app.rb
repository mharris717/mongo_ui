require 'rubygems'
require 'sinatra'
require "/code/mongo_persist/lib/mongo_persist"

class Mongo::Collection
  def keys
    find.map { |x| x.keys }.flatten.uniq.sort.reject { |x| x.to_s[0..0] == '_' }
  end
end

def db
  Mongo::Connection.new.db('test-db')
end

coll = db.collection("test")
coll.remove
coll.save('a' => 'b')
coll.save('c' => 'd', 'a' => 7)

get "/" do
  @coll = coll
  haml :coll
end

post '/new_row' do
  puts params.inspect
end