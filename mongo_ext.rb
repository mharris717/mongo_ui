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

class Object
  def each_size
    res = 0
    each { |x| res += 1 }
    res
  end
end

class Mongo::Collection
  alias_method :old_find, :find
  def find(*args)
    
    #bt
    str = "#{name} find #{args.inspect}"
    res = old_find(*args)
    puts "#{str} #{res.count}"
    res
  end
  def keys
    res = ['_id'] + find.map { |x| x.keys }.flatten.uniq.sort.reject { |x| x.to_s[0..0] == '_' } - ['position']
    raise res.inspect if res.select { |x| x =~ /updated/i }.size > 1
    if name == 'players'
      front = ['_id','name','avg','hr','rbi','sb','bid','value','profit']
      res = front + (res - front)
    end
    res
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
    res = find_one(ops)
    return res if res
    save(ops)
  end
  def find_by_id(row_id)
    row_id = Mongo::ObjectID.from_string(row_id) if row_id.is_a?(String)
    raw_rows = find('_id' => row_id)
    rows = raw_rows.to_a
    row = rows.first
    log "find_by_id", {:coll => name, :id => row_id, :res => row, :rows_size => rows.size, :count => raw_rows.count}
    row
  end
  def update_row(row_id,fields)
    row = (row_id == 'NEW') ? {} : find_by_id(row_id)
    raise "can't find row #{row_id} #{row_id.class} in coll #{name}.  Count is #{find.count} IDs are "+find.to_a.map { |x| x['_id'] }.inspect + "Trying to update with #{fields.inspect}" unless row
    fields.each do |k,v|
      row.dot_set(k,mongo_value(v))
      row.delete(k) if v.blank?
    end
    save(row)
    puts "row is #{row.inspect}"
    row
  end
  def base_name
    name
  end
  def name=(x)
    raise x.to_s
  end
  def search_str; ''; end
  def sort_str; ''; end
  #class << self
    alias_method :old_insert, :insert
    alias_method :old_update, :update
    def insert(h,*args)
      h['_allwords'] = h.without_keys('_allwords').values.join("") + 'abc'
      old_insert(h,*args)
    end
    def update(id,h,*args)
      h['_allwords'] = h.without_keys('_allwords').values.join("") + 'abc'
      old_update(id,h,*args)
    end
  #end
end

module AllHashKeysColl
  def all_hash_keys(field)
    find.map { |row| row[field].all_hash_keys }.flatten.uniq.sort
  end
end

class Mongo::Collection
  include AllHashKeysColl
end