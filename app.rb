$db_name ||= "test-db16"
def db
  Mongo::Connection.new.db($db_name)
end

require File.dirname(__FILE__) + "/requires"
require 'sinatra'




helpers do
  fattr(:coll) do
    Workspace.instance.get_coll(params[:coll])
  end
  fattr(:row_id) { params[:row_id] }
  fattr(:row) do
    raise "no row" unless row_id
    puts "Row ID: #{row_id}"
    coll.find_one(Mongo::ObjectID.from_string(row_id))
  end
  def get_paginated
  end
  def print_params!
    strs = ["#{Time.now}"]
    params.each_sorted_by_key_asc do |k,v|
      strs << "#{k}: #{v}"
    end
    #puts strs.join("\n")
    File.create("log/last_params.txt",strs.join("\n"))
  end
  def table_options_dropdown
    inner = ['','copy','search','pagesize','reload','newrow'].sort.map { |action| "<option value='#{action}'>#{action.humanize}</option>" }.join
    "<select>#{inner}</select>"
  end
  def coll_style(c)
    return "" unless coll.respond_to?(:position)
    "top: #{c.position[:top]}; left: #{c.position[:left]}"
  end
  def get_position(coll)
    return {} unless coll.respond_to?(:user_coll)
    return {} unless coll.user_coll.position
    top = coll.user_coll.position['top'].to_s + "px"
    left = coll.user_coll.position['left'].to_s + "px"
    {:top => top, :left => left}
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
  print_params!
  coll.update_row(params['row_id'], params['field_name'].to_s.downcase => params['field_value'], 'updated_at' => Time.now)
  puts "Updated Row: " + row.inspect + " " + row.map_value { |x| x.class }.inspect
 # puts row['era'].map { |x| x.class }.inspect
  mongo_value(params['field_value']).mongo_inspect
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
  # print_params!
  manager = CollData.new(:coll => coll, :params => params)
  manager.json_str#.tap { |x| puts "JSON STR"; puts x }
end

get "/copy" do
  base =  (coll.respond_to?(:base_coll_name) ? coll.base_coll_name : coll.name)
  new_name = base + "copy#{rand(1000)}"
  puts "creating user collection"
  a = UserCollection.all.size
  UserCollection.create!(:coll_name => new_name, :base_coll_name => base)
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
  player = row['name']
  lucky_page(player)
end

get '/save_position' do
  if coll.respond_to?(:user_coll)
    coll.user_coll.position = {'top' => params[:top], 'left' => params['left']}
    coll.user_coll.save!
  end
end

get '/field_info' do
  ps = params.without_keys('keys')
  File.append("log/field_info.log","#{Time.now} #{ps.inspect}\n")
  f = row[params[:field]]
  if params[:subfield].present?
    sub = params[:subfield]
    sub = sub.to_i if f.kind_of?(Array)
    f = f[sub] 
  end
  cls = f.class.to_s
  cls = 'Hash' if cls == 'OrderedHash'
  {'field_type' => cls, 'value' => f}.to_json.tap { |x| File.append("log/field_info.log","#{Time.now} #{x}\n") }
end
