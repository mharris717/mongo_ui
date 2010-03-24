class Hash
  def map_key
    res = {}
    each { |k,v| res[yield(k)] = v }
    res 
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
  def without_keys(*ks)
    ks = ks.flatten
    res = {}
    each do |k,v|
      res[k] = v unless ks.include?(k)
    end
    res
  end
end

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

class Hash
  def add_to_array(k,*vals)
    self[k] ||= []
    self[k] += vals
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

def bt
  raise 'foo'
rescue => exp
  puts exp.backtrace.join("\n")
end

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
