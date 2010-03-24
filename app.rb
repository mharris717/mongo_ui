require File.dirname(__FILE__) + "/requires"
require 'sinatra'


def db
  Mongo::Connection.new.db('test-db7')
end
    
class Workspace
  class << self
    fattr(:instance) { new }
  end
  def colls
    res = db.collections.reject { |x| x.name == 'system.indexes' || x.name =~ /ufser_/ }
    res += UserCollection.to_colls
    res
  end  
  def get_coll(n)
    colls.find { |x| x.name == n }
  end
end

class Object
  def to_thing
    blank? ? "_" : self
  end
end


helpers do
  fattr(:coll) do
    Workspace.instance.get_coll(params[:coll])
  end
  def get_paginated
  end
end

get "/" do
  @colls = Workspace.instance.colls
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
  find_ops = {:limit => params[:iDisplayLength].to_i, :skip => params[:iDisplayStart].to_i}
  puts "before rows"
  rows = coll.find({},find_ops).to_a
  puts "after rows"
  ks = coll.keys
  data = rows.map do |row|
    ks.map { |k| row[k].to_thing }
  end
  {:sEcho => params[:sEcho], :iTotalRecords => coll.find.count, :iTotalDisplayRecords => rows.size, :aaData => data}.to_json.tap { |x| puts x.inspect }
end
