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
    #MockColl.new(:sort_conditions => sort_conditions, :name => coll_name, :base_coll_name => base_coll_name)
    MockColl.from_hash_safe(:user_coll => self, :sort_conditions => sort_conditions, :filter_conditions => filter_conditions, :coll_name => coll_name, :base_coll_name => base_coll_name, :search_str => search_str, :position => position)
  end
  def self.to_colls
    all.map { |x| x.to_coll }
  end
end


class GroupedUserCollection
  include MongoMapper::Document
  key :coll_name
  key :base_coll_name
  key :group_key
  key :sum_fields
  def to_coll
    MockGroupColl.from_hash_safe(attributes)
  end
  def self.to_colls
    all.map { |x| x.to_coll }
  end
end

class Array
  def average
    sum.to_f / size.to_f
  end
end

class TeamPosCollection
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
      #puts ps.map { |p| p[col] * p[dcol] }.inspect
      top = ps.map { |p| p[col] * p[dcol] }.sum
      bottom = res[dcol]
      bottom = 1 if bottom == 0
      #puts "#{ps.first['team']} #{col} top #{top.to_f} bottom #{bottom.to_f}"
      res[col] = (top.to_f / bottom.to_f).to_s[0...5].to_f
      #res[col] = ps.map { |x| x[col] }.select { |x| x > 0 }.average
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
      #{'team' => ps.first['team'], 'hr' => ps.map { |x| x['hr'] }.sum, '_id' => rand(10000000000) }
      team_row(ps)
    end.select { |x| x }
  end
  def keys
    ['_id','team','pa','hr','rbi','sb','avg','ip','w','sv','era','whip','spent','left','value','numplayers','playersleft']
  end
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
  def name
    "vals"
  end
  def search_str; ''; end
  def sort_str; ''; end
end

class MockGroupColl
  attr_accessor :coll_name, :base_coll_name, :group_key, :sum_fields, :position 
  fattr(:groups_hash) do
    db.collection(base_coll_name).sum_by(:key => group_key, :sum_fields => sum_fields)
  end
  def group_rows
    res = []
    groups_hash.each do |k,v|
      res << {'_id' => rand(10000000000000), 'team' => k, 'value' => v}
    end
    res
  end
  def find(selector={}, ops={})
    res = group_rows
    res = res.sort_by { |x| x[ops[:sort].first.first] || '' } if ops[:sort]
    res = res.reverse if ops[:sort] && ops[:sort].first.last.to_s == 'desc'
    res
  end
  def name
    coll_name 
  end
  def search_str; ''; end
  def sort_str; ''; end
  def keys; ['_id','team','value'] end
end

class Array
  def count
    size
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


 
