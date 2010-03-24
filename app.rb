require 'rubygems'
require 'sinatra'
if ARGV.include?('--localmp')
  require "/code/mongo_persist/lib/mongo_persist"
else
  require 'mongo_persist'
end
require 'haml'
require 'mongo_scope'
require 'activesupport'

def db
  Mongo::Connection.new.db('test-db7')
end

class Order
  include MongoPersist
  attr_accessor :po_number, :customers, :some_hash
  mongo_reference_attributes ['customers']
  fattr(:order_products) { [] }
  def products
    order_products.map { |x| x.product }
  end
  def subtotal
    order_products.map { |x| x.subtotal }.sum
  end
end

class OrderProduct
  include MongoPersist
  attr_accessor :unit_price, :quantity, :product
  mongo_reference_attributes ['product']
  def subtotal
    quantity.to_f * unit_price
  end
end

class Product
  include MongoPersist
  attr_accessor :name
end

class Customer
  include MongoPersist
  attr_accessor :email
end

    # [Order,Product].each { |x| x.collection.remove }
    # @products = [Product.new(:name => 'Leather Couch'),Product.new(:name => 'Maroon Chair')].each { |x| x.mongo.save! }
    # @customers = [Customer.new(:email => 'a'),Customer.new(:email => 'b')].each { |x| x.mongo.save! }
    # 
    # @orders = []
    # @orders << Order.new(:customers => @customers, :po_number => 1234, :order_products => [OrderProduct.new(:unit_price => 1000, :quantity => 1, :product => @products[0])]).mongo.save!
    # @orders << Order.new(:customers => @customers, :po_number => 1235, :order_products => [OrderProduct.new(:unit_price => 200, :quantity => 2, :product => @products[1])]).mongo.save!
    
class Object
  def eval_one(str)
    puts instance_eval(str).inspect
  rescue
    puts "error"
  end
  def eval_loop
    loop do
      str = STDIN.gets
      return if str.strip == 'end'
      eval_one(str)  
    end
  end
end

def bt
  raise 'foo'
rescue => exp
  puts exp.backtrace.join("\n")
end

module Stuff
  def find(*args)
    puts "find #{args.inspect}"
    bt
    super
  end
end
  
class Mongo::Collection
  alias_method :old_find, :find
  def find(*args)
    puts "find #{args.inspect}"
    #bt
    old_find(*args)
  end
  def keys
    find.map { |x| x.keys }.flatten.uniq.sort.reject { |x| x.to_s[0..0] == '_' }
  end
  def to_csv
    arr = []
    ks = keys
    arr << ks.join(",")
    find.each do |row|
      arr << ks.map { |k| row[k] }.join(",")
    end
    arr.join("\n")
  end
  def find_or_create(ops)
    return if find_one(ops)
    save(ops)
  end
  def update_row(row_id,fields)
    #puts "updating #{row_id} with #{fields.inspect}"
    #eval_loop
    row_id = Mongo::ObjectID.from_string(row_id) if row_id.is_a?(String)
    row = find('_id' => row_id).to_a.first
    raise "can't find row #{row_id} #{row_id.class} in coll #{name}.  Count is #{find.count} IDs are "+find.to_a.map { |x| x['_id'] }.inspect + "Trying to update with #{fields.inspect}" unless row
    fields.each do |k,v|
      row[k] = mongo_value(v)
      row.delete(k) if v.blank?
    end
    save(row)
  end
  def base_name
    name
  end
  def name=(x)
    raise x.to_s
  end
end

class MongoScope::ScopedCollection
  def name
    "#{coll.name} scoped"
  end
end

class Hash
  def add_to_array(k,*vals)
    self[k] ||= []
    self[k] += vals
  end
end

class ProxyColl
  attr_accessor :coll
  include FromHash
  def method_missing(sym,*args,&b)
    puts "mm #{sym} #{args.inspect}"
    coll.send(sym,*args,&b)
  end
  def base_name
    coll.base_name
  end
  def name
    "#{coll.name}, #{addl_name}"
  end
  def find(selector={},ops={},&b)
    modify_find_ops(selector,ops)
    puts "running find with selector #{selector.inspect} ops #{ops.inspect}"
    coll.find(selector,ops,&b)
  end
end

class SortedColl < ProxyColl
  attr_accessor :sort_ops
  def modify_find_ops(selector,ops)
    ops.add_to_array(:sort,*sort_ops)
  end
  def addl_name
    "Sort by " + sort_ops.map { |x| x.join(" ") }.join(",")
  end
end

class Mongo::DB
  def get_coll(name)
    puts "get_coll #{name}"
    if !(name =~ /,/)
      collection(name)
    else
      base_name = name.split(",").first.strip
      base_coll = collection(base_name)
      sort_str = name.split(",").last.gsub(/sort by/i,"").strip
      field,dir = *sort_str.split(" ").map { |x| x.strip }
      ops = {:coll => base_coll, :sort_ops => [[field,dir.to_sym]]}
      puts "get_coll ops #{ops.inspect}"
      SortedColl.new(ops)
    end
  end
end
db.collection('players').tap do |c|
  c.remove
  c.find_or_create(:name => 'Albert Pujols', :position => '1B', :value => 62)
  c.find_or_create(:name => 'David Wright', :position => '3B', :value => 55, :team => 'Panda')
  c.find_or_create(:name => 'Roy Halladay', :position => 'SP', :value => 45)
  c.find_or_create(:name => 'Ryan Zimmerman', :position => '3B', :value => 27)
  c.find_or_create(:name => 'Michael Bourn', :position => 'OF', :value => 27)
  c.find_or_create(:name => 'Hanley Ramirez', :position => 'SS', :value => 65)
  (2..10).each do |i|
    c.find_or_create(:name => "Albert Pujols#{i}", :position => "1B", :value => 62)
    c.find_or_create(:name => "David Wright#{i}", :position => "3B", :value => 55, :team => "Panda")
    c.find_or_create(:name => "Roy Halladay#{i}", :position => "SP", :value => 45)
    c.find_or_create(:name => "Ryan Zimmerman#{i}", :position => "3B", :value => 27)
    c.find_or_create(:name => "Michael Bourn#{i}", :position => "OF", :value => 27)
    c.find_or_create(:name => "Hanley Ramirez#{i}", :position => 'SS', :value => 65)
  end
end

class Foo
  class << self
    fattr(:colls) do
      ['c1','c2'].map do |n|
        coll = db.collection(n)
        coll.remove
        coll.save('name' => 'Mike')
        coll.save('name' => 'Dave', 'age' => 25)
        coll.save('name' => 'Lowell', 'age' => 39, 'schools' => ['Williams','Columbia','George Mason'])
        coll
      end
    end
  end
end

#Foo.colls


class Object
  def self.from_hash_safe(ops)
    res = new
    ops.each do |k,v|
      res.send_if_respond("#{k}=",v)
    end
    res 
  end
  def send_if_respond(k,v)
    send(k,v) if respond_to?(k)
  end
end

require 'mongo_mapper'
MongoMapper.database = 'test-db7'
class UserCollection
  include MongoMapper::Document
  key :sort_conditions
  key :coll_name
  key :base_coll_name
  def to_coll
    #MockColl.new(:sort_conditions => sort_conditions, :name => coll_name, :base_coll_name => base_coll_name)
    MockColl.from_hash_safe(attributes.merge(:user_coll => self))
  end
  def self.to_colls
    all.map { |x| x.to_coll }
  end
end

class MockColl
  attr_accessor :sort_conditions, :filter_conditions, :coll_name, :base_coll_name, :user_coll
  include FromHash
  def raw_base_coll
    db.collection(base_coll_name)
  end
  def sorted_base_coll
    sort_conditions ? SortedColl.new(:coll => filtered_base_coll, :sort_ops => sort_conditions) : filtered_base_coll
  end
  def filtered_base_coll
    filter_conditions ? raw_base_coll.scope_eq(filter_conditions) : raw_base_coll
  end
  def find(selector={},ops={})
    sorted_base_coll.find(selector,ops)
  rescue
    []
  end
  def keys
    #eval_loop
    #puts "self #{self.class} #{self.coll_name}, base #{base_coll.class} #{base_coll.name}"
    raw_base_coll.keys
  end
  def name; coll_name; end
  def method_missing(sym,*args,&b)
    sorted_base_coll.send(sym,*args,&b)
  end
end

UserCollection.all.each { |x| x.destroy }
UserCollection.create!(:coll_name => 'PlayersbyValue', :base_coll_name => 'players', :sort_conditions => [['value',:desc]])
# UserCollection.create!(:coll_name => 'PandaPlayers', :base_coll_name => 'players', :filter_conditions => {:team => 'Panda'})
# UserCollection.create!(:coll_name => 'AvailablePlayers', :base_coll_name => 'players', :filter_conditions => {:team => nil})

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
  def raw_value
    if kind_of?(String)
      self
    elsif nil?
      ""
    else
      inspect
    end
  end
end

class Hash
  def map_key
    res = {}
    each { |k,v| res[yield(k)] = v }
    res 
  end
end

def mongo_value(v)
  if v[0..0] == '['
    #v[1...-1].split(",").map { |x| x.tmo }
    eval(v).map { |x| x.tmo }
  elsif v[0..0] == '{'
    eval(v).map_key { |x| x.tmo }.map_value { |x| x.tmo }
  else
    v.tmo
  end
end

class Object
  def mongo_inspect
    "#{self}"
  end
  def tmo
    self
  end
end

class Numeric
  def tmo
    (self == to_i) ? to_i : self
  end
end

class String
  def num?
    self =~ /^[\d\.]*$/
  end
  def tmo
    if num? 
      to_f.tmo 
    elsif blank?
      nil
    else
      self
    end
  end
end

class Array
  def mongo_inspect
    if contains_array?
      "<ul>" + map { |x| "<li>#{x.mongo_inspect}</li>" }.join("") + "</ul>"
    else
      map { |x| x.mongo_inspect }.join(",")
    end
  end
  def contains_array?
    any? { |x| x.kind_of?(Array) }
  end
end

class Hash
  def mongo_inspect
    "<ul>" + map { |k,v| "<li>#{k.mongo_inspect}: #{v.mongo_inspect}</li>" }.join("") + "</ul>"
  end
end

class Hash
  def without_keys(*ks)
    ks = ks.flatten
    res = {}
    each do |k,v|
      res[k] = v unless ks.include?(k)
    end
    res
  end
end

helpers do
  fattr(:coll) do
    Workspace.instance.get_coll(params[:coll])
  end
  def get_paginated
  end
end

def myget(*args,&b)
  get(*args) do
    #puts "Params: #{params.inspect}"
    instance_eval(&b)
  end
end

myget "/" do
  @colls = Workspace.instance.colls
  haml :db
end

myget '/new_row' do
  new_params = params.without_keys('coll','newField').map_value { |v| mongo_value(v) }
  coll.save(new_params)
end

myget '/update_row' do
  coll.update_row(params['row_id'], params['field_name'] => params['field_value'])
  params['field_value']
end

myget '/table' do
  if params[:format] == 'csv'
    content_type 'application/csv'
    attachment "#{params[:coll]}.csv"
    coll.to_csv
  else
    haml :coll, :locals => {:coll => coll}
  end
end

class Object
  def to_thing
    blank? ? "_" : self
  end
end

myget "/table2" do
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

def assert_mongo_value(str,exp)
  res = mongo_value(str)
  if res != exp
    raise "Expected #{exp.inspect}, got #{res.inspect}"
  end
end

assert_mongo_value "[1,2,3]",[1,2,3]
assert_mongo_value "{1 => 2}", {1 => 2}
