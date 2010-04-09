require 'mongo_mapper'
MongoMapper.database = $db_name
class UserCollection
  include MongoMapper::Document
  key :sort_conditions
  key :filter_conditions
  key :coll_name
  key :base_coll_name
  key :search_str
  key :position
  def set_search_str(str)
    self.search_str = str
    self.filter_conditions = SearchStr.new(:str => str).selector
  end
  def to_coll
    MockColl.from_hash_safe(:user_coll => self, :sort_conditions => sort_conditions, :filter_conditions => filter_conditions, :coll_name => coll_name, :base_coll_name => base_coll_name, :search_str => search_str, :position => position)
  end
  fattr(:special_coll_hash) do
    {'team_pos' => TeamPosCollection.new, 'bet_table' => BetTable.new, 'foo' => FooColl.new}
  end
  fattr(:base_coll) do
    special_coll_hash[base_coll_name] || db.collection(base_coll_name)
  end
  def self.to_colls
    all.map { |x| x.to_coll }
  end
  def all_hash_keys(field)
    base_coll.all_hash_keys(field)
  end
end

module MockFind
  def default(rows,field)
    return 0 if rows.map { |x| x[field] }.any? { |x| x.kind_of?(Numeric) }
    ''
  end
  def find(selector={}, ops={})
    res = rows
    default = default(res,ops[:sort].first.first) if ops[:sort]
     res = res.sort_by { |x| x[ops[:sort].first.first] || default } if ops[:sort]
     res = res.reverse if ops[:sort] && ops[:sort].first.last.to_s == 'desc'
    res
  end
end

class Array
  def to_f
    1
  end
end

class Object
  def to_i
    17
  end
  def to_f
    1
  end
end

module AddlColumns
  def addl_column(name,&b)
    self.addl_columns[name] = b
  end
  fattr(:addl_columns) { {} }
  def add_column_value(row,b)
    b[row]
  rescue
    "Error"
  end
  def add_addl_columns!(row)
    addl_columns.each do |name,b|
      row[name.to_s] = add_column_value(row,b)
    end
  end
end

class BetTable
  extend AddlColumns
    include AllHashKeysColl
  fattr(:base_coll) { db.collection('raw_bets') }
  def keys
    base_coll.keys + addl_keys
  end
  def addl_keys
    ['amount_bet']
  end
  addl_column(:amount_bet) do |row|
    row['line'].map { |x| x['amount'].to_i }.sum
  end
  def find(selector={},ops={})
    res = base_coll.find(selector,ops).to_a
    #res.each { |x| x['amount_bet'] = 42 }
    res.each do |row|
      klass.add_addl_columns!(row)
    end
    log :bet_table, "find", {:selector => selector, :ops => ops, :res_size => res.size, :res_class => res.class}
    res
  end
  def method_missing(sym,*args,&b)
    base_coll.send(sym,*args,&b)
  end
end

class TeamPosCollection
  include MockFind
  def pos(player)
    res = player['position'].split(",").first
    res = 'P' if res =~ /SP/ || res =~ /RP/
    res = 'OF' if res =~ /F/
    res
  end
  def team_row(ps)
    ps = ps.select { |x| x['bid'].to_i > 0 }
    return nil if ps.empty?
    res = {'team' => ps.first['team'], '_id' => rand(10000000000) }
    %w(hr rbi sb w sv pa ip bid value).each do |col|
      res[col] = ps.map { |x| x[col].to_i }.sum
    end
    %w(avg era whip).each do |col|
      dcol = (col == 'avg') ? 'pa' : 'ip'
      top = ps.map { |p| p[col].to_f * p[dcol].to_f }.sum
      bottom = res[dcol]
      bottom = 1 if bottom == 0
      res[col] = (top.to_f / bottom.to_f).to_s[0...5].to_f
    end
    res['spent'] = res['bid']
    res['needed'] = 23 - ps.size
    res['left'] = 260 - res['spent']
    res['numplayers'] = ps.size
    res['playersleft'] = 23-ps.size
    res
  end
  fattr(:rows) do
    db.collection('players').find(:team => /./).group_by { |x| x['team'] }.values.map do |ps|
      team_row(ps)
    end.select { |x| x }
  end
  def keys
    ['_id','team','pa','hr','rbi','sb','avg','ip','w','sv','era','whip','spent','left','value','numplayers','playersleft']
  end
end

class FooColl
  include MockFind
  def keys
    ['_id','a','b']
  end
  def rows
    [{'a' => 2, 'b' => 17}]
  end
end

class MockColl
  attr_accessor :sort_conditions, :filter_conditions, :coll_name, :base_coll_name, :user_coll, :search_str
  include FromHash
  def base_coll
    user_coll.base_coll
  end
  def sorted_base_coll
    sort_conditions ? SortedColl.new(:coll => filtered_base_coll, :sort_ops => sort_conditions) : filtered_base_coll
  end
  def filtered_base_coll
    (filter_conditions && !filter_conditions.empty?) ? base_coll.scope_eq(filter_conditions) : base_coll
  end
  def find(selector={},ops={})
    puts "sort_conditions #{sort_conditions.inspect} ops #{ops.inspect}"
    sorted_base_coll.find(selector,ops)
  #rescue
  #  []
  end
  def keys
    base_coll.keys
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
  def all_hash_keys(field)
    user_coll.all_hash_keys(field)
  end
end

class UserCollection
  def copy!
    new_name = base_coll_name + "copy#{rand(100000)}"
    UserCollection.create!(:coll_name => new_name, :base_coll_name => base_coll_name)
  end
end

 
