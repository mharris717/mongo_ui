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
#    puts "running find with selector #{selector.inspect} ops #{ops.inspect}"
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

class MongoScope::ScopedCollection
  def name
    "#{coll.name} scoped"
  end
end