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
    res = old_find(*args)
    puts "#{name} find #{args.inspect}   #{res.count}"
    res
  end
  def keys
    res = ['_id'] + find.map { |x| x.keys }.flatten.uniq.sort.reject { |x| x.to_s[0..0] == '_' } - ['position']
    raise res.inspect if res.select { |x| x =~ /updated/i }.size > 1
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