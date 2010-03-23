require 'rubygems'
require 'sinatra'
if ARGV.include?('--localmp')
  require "/code/mongo_persist/lib/mongo_persist"
else
  require 'mongo_persist'
end
require 'haml'
require 'mongo_scope'
require 'active_support'

def db
  Mongo::Connection.new.db('test-db6')
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

  
class Mongo::Collection
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
    puts "updating #{row_id} with #{fields.inspect}"
    #eval_loop
    row_id = Mongo::ObjectID.from_string(row_id) if row_id.is_a?(String)
    row = find('_id' => row_id).to_a.first
    raise "can't find row #{row_id} #{row_id.class} in coll #{name}.  Count is #{find.count} IDs are "+find.to_a.map { |x| x['_id'] }.inspect + "Trying to update with #{fields.inspect}" unless row
    fields.each do |k,v|
      row[k] = v
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
  c.find_or_create(:name => 'Hanley Ramirez', :position => 'SS', :value => 65)
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

def get_all_colls
  res = db.collections.reject { |x| x.name == 'system.indexes' }
  players = res.first
  res << SortedColl.new(:coll => res.first, :sort_ops => [['value',:desc]])
  res << res.first.scope_exists(:team => false)
  res
end

require 'mongo_mapper'
MongoMapper.database = 'test-db6'
class UserTable
  include MongoMapper::Document
  has_many :sort_conditions
  key :name
  key :base_table_name
end

UserTable.all.each { |x| x.destroy }
UserTable.new(:name => 'Players by Value')

get "/" do
  @colls = get_all_colls
  haml :coll
end

def mongo_value(v)
  if v[0..0] == '['
    v[1...-1].split(",").map { |x| x.tmo }
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
    num? ? to_f.tmo : self
  end
end

class Array
  def mongo_inspect
    "<ul>" + map { |x| "<li>#{x.mongo_inspect}</li>" }.join("") + "</ul>"
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

get '/new_row' do
  puts params.inspect
  coll = db.collection(params[:coll])
  new_params = params.without_keys('coll','newField').map_value { |v| mongo_value(v) }
  coll.save(new_params)
end

get '/update_row' do
  coll = db.get_coll(params[:coll])
  coll.update_row(params['row_id'], params['field_name'] => params['field_value'])
  params['field_value']
end

get '/table' do
  coll = db.get_coll(params[:coll])
  if params[:format] == 'csv'
    content_type 'application/csv'
    attachment "#{params[:coll]}.csv"
    coll.to_csv
  else
    haml :table, :locals => {:coll => coll}
  end
end
