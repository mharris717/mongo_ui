$db_name ||= "test-db16"
def db
  Mongo::Connection.new.db($db_name)
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
    # u = UserCollection.find_one(:coll_name => 'recent') 
    #  u.filter_conditions = {:updated_at => {'$gt' => 30.minutes.ago}}
    #  u.save!
    #res += GroupedUserCollection.to_colls
    res << TeamPosCollection.new
    #raise res.size.to_s
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
  def table_options_dropdown
    res = "<select>"
    ['','copy','search'].each do |action|
      res += "<option value='#{action}'>#{action.humanize}</option>"
    end
    res += "</select>"
    res
  end
  def coll_style(c)
    return "" unless coll.respond_to?(:position)
    "top: #{c.position[:top]}; left: #{c.position[:left]}"
  end
end

get "/" do
  puts "COL SIZE: " + db.collections.map { |x| x.name }.inspect
  @colls = Workspace.instance!.colls
  UserCollection.all.each { |x| puts x.inspect }
  haml :db
end

get '/new_row' do
  new_params = params.without_keys('coll','newField').map_value { |v| mongo_value(v) }
  coll.save(new_params)
end

get '/update_row' do
  coll.update_row(params['row_id'], params['field_name'].to_s.downcase => params['field_value'], 'updated_at' => Time.now)
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
  manager.json_str.tap { |x| puts x }
end

get "/copy" do
  new_name = coll.name + "copy#{rand(1000)}"
  puts "creating user collection"
  a = UserCollection.all.size
  UserCollection.create!(:coll_name => new_name, :base_coll_name => coll.name)
  puts "UC count #{a} #{UserCollection.all.size}"
  redirect "/"
end

get "/rename" do
  coll.rename(params[:new_name])
  params[:new_name]
end

def lucky_page(name)
  require 'open-uri'
  url = "http://www.google.com/search?q=fangraphs #{name}&btnI=Im+Feeling+Lucky".gsub(/ /,"+")
  puts url
  url
  #puts url
  #open(url) { |f| f.read }
end

get '/cell_edit' do
  row = coll.find_one(Mongo::ObjectID.from_string(params[:row_id]))
  player = row['name']
  lucky_page(player)
end
