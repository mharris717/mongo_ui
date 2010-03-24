def db
  Mongo::Connection.new.db('test-db7')
end

require File.dirname(__FILE__) + "/requires"
require 'sinatra'



    
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
  def print_params!
    strs = []
    params.each_sorted_by_key_asc do |k,v|
      strs << "#{k}: #{v}"
    end
    puts strs.join("\n")
    File.create("log/last_params.txt",strs.join("\n"))
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

class CollData
  attr_accessor :coll, :params
  include FromHash
  fattr(:search_str) { params[:sSearch] }
  fattr(:search_terms) { search_str.split(" ").map { |x| x.strip }.select { |x| x.present? } }
  fattr(:find_ops) do
    {:limit => params[:iDisplayLength].to_i, :skip => params[:iDisplayStart].to_i}
  end
  def search_field_hash(term)
    parts = term.split(':').map { |x| x.strip }
    if parts.size == 1
      return {'_allwords' => /#{term}/i}
    elsif parts.size == 2
      field, value = *parts
      {field => /#{value}/i}
    elsif parts.size == 3
      field, op, value = *parts
      {field => {"$#{op}" => value.to_f}}
    else
      raise "bad"
    end
  end
  def selector
    return {} unless search_str.present?
    search_terms.inject({}) do |h,term|
      h.merge(search_field_hash(term))
    end
  end
  fattr(:rows) do
    coll.find(selector,find_ops).to_a
  end
  fattr(:unpaginated_count) do
    coll.find(selector,{}).count
  end
  fattr(:keys){ coll.keys }
  fattr(:data) do
    rows.map do |row|
      keys.map { |k| row[k].to_thing }
    end
  end
  fattr(:json_hash) do
    {:sEcho => params[:sEcho], :iTotalRecords => coll.find.count, :iTotalDisplayRecords => unpaginated_count, :aaData => data}
  end
  fattr(:json_str) do
    puts json_hash.without_keys(:aaData).merge(:rows_size => json_hash[:aaData].size).inspect
    json_hash.to_json
  end
end

get "/table2" do
  print_params!
  manager = CollData.new(:coll => coll, :params => params)
  manager.json_str
end
