# players are in 16
$db_name ||= "test-db17"
def db
  Mongo::Connection.new.db($db_name)
end

require File.dirname(__FILE__) + "/requires"
require 'sinatra'

def is(coll)
  coll.find.to_a.map { |x| x['_id'].to_s[0..-1] }
end


helpers do
  fattr(:coll) do
    res = Workspace.instance.get_coll(params[:coll])
    log 'coll',"getting coll #{params[:coll]}", :res => res
    puts 'coll ' + is(res).inspect
    res
  end
  fattr(:base_coll) do
    res = coll
    res = coll.base_coll if coll.respond_to?(:base_coll)
    res
  end
  fattr(:row_id) { params[:row_id] }
  fattr(:row) do
    raise "no row" unless row_id
    puts "Row ID: #{row_id}"
    puts 'before ' + is(coll).inspect
    res = base_coll.find_by_id(Mongo::ObjectID.from_string(row_id))
    log :row, "base_coll: #{base_coll.name} id: #{row_id}"
    raise "no row found for #{row_id}. Rows are " + is(coll).inspect unless res
    res
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
  fattr(:field_info) { FieldInfo.new(params.with_keys('field','subfield').merge(:coll => coll, :row => row)) }
end

get "/" do
  @colls = Workspace.instance!.colls
  haml :db
end

get '/new_row' do
  new_params = params.without_keys('coll','newField').map_value { |v| mongo_value(v) }
  coll.save(new_params)
end

get '/update_row' do
  print_params!
  coll.update_row(params['row_id'], params['field_name'].to_s.downcase => params['field_value'], 'updated_at' => Time.now)
  log :update_row, "Updated Row: " + row.inspect + " " + row.map_value { |x| x.class }.inspect
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
  manager = CollData.new(:coll => coll, :params => params)
  manager.json_str#.tap { |x| puts "JSON STR"; puts x }
end

get "/copy" do
  coll.copy!
  redirect "/"
end

get "/rename" do
  coll.rename(params[:new_name])
  params[:new_name]
end

get '/save_position' do
  #if coll.respond_to?(:user_coll)
    coll.user_coll.position = {'top' => params[:top], 'left' => params['left']}
    coll.user_coll.save!
  #end
end

get '/field_info' do
  log :field_info, params
  field_info.json_str
end

get "/log" do
  log :js, params[:str]
end




