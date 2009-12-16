require 'rubygems'
require 'sinatra'
require "/code/mongo_persist/lib/mongo_persist"
require 'haml'


def db
  Mongo::Connection.new.db('test-db3')
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

    [Order,Product].each { |x| x.collection.remove }
    @products = [Product.new(:name => 'Leather Couch'),Product.new(:name => 'Maroon Chair')].each { |x| x.mongo.save! }
    @customers = [Customer.new(:email => 'a'),Customer.new(:email => 'b')].each { |x| x.mongo.save! }

    @orders = []
    @orders << Order.new(:customers => @customers, :po_number => 1234, :order_products => [OrderProduct.new(:unit_price => 1000, :quantity => 1, :product => @products[0])]).mongo.save!
    @orders << Order.new(:customers => @customers, :po_number => 1235, :order_products => [OrderProduct.new(:unit_price => 200, :quantity => 2, :product => @products[1])]).mongo.save!

  
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

Foo.colls

get "/" do
  @colls = db.collections.reject { |x| x.name == 'system.indexes' }
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

get '/table' do
  coll = db.collection(params[:coll])
  if params[:format] == 'csv'
    content_type 'application/csv'
    attachment "#{params[:coll]}.csv"
    coll.to_csv
  else
    haml :table, :locals => {:coll => coll}
  end
end
