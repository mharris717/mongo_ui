require 'mongo_mapper'
MongoMapper.database = $db_name
class UserCollection
  include MongoMapper::Document
  key :sort_conditions
  key :filter_conditions
  key :coll_name
  key :base_coll_name
  key :search_str
  def set_search_str(str)
    self.search_str = str
    self.filter_conditions = SearchStr.new(:str => str).selector
  end
  def to_coll
    #MockColl.new(:sort_conditions => sort_conditions, :name => coll_name, :base_coll_name => base_coll_name)
    MockColl.from_hash_safe(:user_coll => self, :sort_conditions => sort_conditions, :filter_conditions => filter_conditions, :coll_name => coll_name, :base_coll_name => base_coll_name, :search_str => search_str)
  end
  def self.to_colls
    all.map { |x| x.to_coll }
  end
end

class MockColl
  attr_accessor :sort_conditions, :filter_conditions, :coll_name, :base_coll_name, :user_coll, :search_str
  include FromHash
  def raw_base_coll
    db.collection(base_coll_name)
  end
  def sorted_base_coll
    sort_conditions ? SortedColl.new(:coll => filtered_base_coll, :sort_ops => sort_conditions) : filtered_base_coll
  end
  def filtered_base_coll
    (filter_conditions && !filter_conditions.empty?) ? raw_base_coll.scope_eq(filter_conditions) : raw_base_coll
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
  def rename(new_name)
    user_coll.update_attributes(:coll_name => new_name)
  end
  def sort_str
    return '' unless sort_conditions && sort_conditions.size > 0
    k = keys.index(sort_conditions.first.first)
    "[[#{k},'#{sort_conditions.first.last}']]"
  end
end

puts "#{UserCollection.all.size} UserCollections"
UserCollection.all.each { |x| x.destroy }
# UserCollection.create!(:coll_name => 'PlayersbyValue', :base_coll_name => 'players', :sort_conditions => [['value',:desc]])
# UserCollection.create!(:coll_name => 'PandaPlayers', :base_coll_name => 'players', :filter_conditions => {:team => 'Panda'})
# UserCollection.create!(:coll_name => 'AvailablePlayers', :base_coll_name => 'players', :filter_conditions => {:team => nil})

