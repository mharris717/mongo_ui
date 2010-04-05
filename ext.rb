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

class Hash
  def self.sort_procs
    res = {}
    res[:key_asc] = lambda { |k,v| k }
    res[:key_desc] = [lambda { |k,v| k },{:reverse => true}]
    res[:value_asc] = lambda { |k,v| v }
    res[:value_desc] = [lambda { |k,v| v },{:reverse => true}]
    res
  end
  def self.get_sort_proc(type)
    [sort_procs[type.to_sym]].flatten[0]
  end
  def self.get_sort_ops(type)
    [sort_procs[type]].flatten[1] || {}
  end
  def self.define_each_methods!
    sort_procs.keys.each do |sort_name|
      %w(each map).each do |type|
        str = "
        def #{type}_sorted_by_#{sort_name}(&b)
          p = self.class.get_sort_proc(:#{sort_name})
          ops = self.class.get_sort_ops(:#{sort_name})
          #{type}_sorted(p,ops,&b)
        end"
        class_eval str
      end
    end
  end
  define_each_methods!
  def each_sorted(sort_proc,ops={})
    sorted_items = to_a.sort_by { |a| sort_proc[a[0],a[1]] }
    sorted_items = sorted_items.reverse if ops[:reverse]
    sorted_items.each do |a|
      yield(a[0],a[1])
    end
  end
  def map_sorted(sort_proc,ops={})
    res = []
    each_sorted(sort_proc,ops) do |k,v|
      res << yield(k,v)
    end
    res
  end
end

class Hash
  def values_in_key_order(ks)
    ks.map { |x| self[x] }
  end
end

class Array
  def uniq_by
    h = {}
    res = []
    each do |x|
      k = yield(x)
      res << x unless h[k]
      h[k] = true
    end
    res
  end
end

class Array
  def average
    sum.to_f / size.to_f
  end
end

class Array
  def count
    size
  end
end