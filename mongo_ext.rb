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

class Mongo::Collection
  # alias_method :old_find, :find
  # def find(*args)
  #   puts "find #{args.inspect}"
  #   #bt
  #   old_find(*args)
  # end
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