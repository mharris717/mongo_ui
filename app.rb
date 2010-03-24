def db
  Mongo::Connection.new.db('test-db9')
end

require File.dirname(__FILE__) + "/requires"
require 'sinatra'



    
class Workspace
  class << self
    fattr(:instance) { new }
  end
  def colls
    res = db.collections.reject { |x| x.name == 'system.indexes' || x.name =~ /user_/ }
    res += UserCollection.to_colls
    res
  end  
  def get_coll(n)
    colls.find { |x| x.name == n }
  end
end

helpers do
  fattr(:coll) do
    Workspace.instance.get_coll(params[:coll])
  end
  def get_paginated
  end
  def print_params!
    strs = []
    params.each_sorted_by_key_asc do |k,v|
      strs << "#{k}: #{v}"
    end
    #puts strs.join("\n")
    File.create("log/last_params.txt",strs.join("\n"))
  end
end

get "/" do
  @colls = Workspace.instance!.colls
  UserCollection.all.each { |x| puts x.inspect }
  haml :db
end

get '/new_row' do
  new_params = params.without_keys('coll','newField').map_value { |v| mongo_value(v) }
  coll.save(new_params)
end

get '/update_row' do
  coll.update_row(params['row_id'], params['field_name'] => params['field_value'])
  params['field_value']
end

get '/table' do
  if params[:format] == 'csv'
    content_type 'application/csv'
    attachment "#{params[:coll]}.csv"
    coll.to_csv
  else
    haml :coll, :locals => {:coll => coll}
  end
end

get "/table2" do
  print_params!
  manager = CollData.new(:coll => coll, :params => params)
  manager.json_str
end

get "/copy" do
  new_name = coll.name + "copy"
  puts "creating user collection"
  a = UserCollection.all.size
  UserCollection.create!(:coll_name => new_name, :base_coll_name => coll.name)
  puts "UC count #{a} #{UserCollection.all.size}"
  redirect "/"
end
