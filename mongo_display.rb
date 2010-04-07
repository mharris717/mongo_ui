def mongo_value(v)
  if v.kind_of?(Time)
    v
  elsif v.kind_of?(String)
    if v[0..0] == '['
      #v[1...-1].split(",").map { |x| x.tmo }
      eval(v).map { |x| mongo_value(x.tmo) }
    elsif v[0..0] == '{'
      eval(v).map_key { |x| x.tmo }.map_value { |x| mongo_value(x.tmo) }
    else
      v.tmo
    end
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
    if num? 
      to_f.tmo 
    elsif blank?
      nil
    else
      self
    end
  end
end

module Enumerable
  def map_join(&b)
    map(&b).join
  end
end

class Array
  def myget(k)
    raise "tried to send #{k} to #{self.inspect}" if k.is_a?(String)
    self[k]
  end
end

def mongo_inspect_hash(ks,rows)
  #"<ul>" + map { |k,v| "<li>#{k.mongo_inspect}: #{v.mongo_inspect}</li>" }.join("") + "</ul>"
  with_tag(:table) do
    head = with_tag(:tr) do
      ks.map_join { |k| with_tag(:th) { k.mongo_inspect } }
    end
    body = rows.map_join do |row|
      puts row.inspect
      with_tag(:tr) do
        ks.map_join { |k| with_tag(:td) { row[k].mongo_inspect } }
      end
    end
    head + body
  end
#rescue
  #raise "Called mongo_inspect_hash with ks #{ks.inspect} and rows #{rows.inspect}"
end

def with_tag(t)
  "<#{t}>" + yield + "</#{t}>"
end

class Array
  def mongo_inspect
    if contains_array?
      "<ul>" + map { |x| "<li>#{x.mongo_inspect}</li>" }.join("") + "</ul>"
    elsif contains_all_hashes?
      ks = map { |x| x.keys }.flatten.uniq
      mongo_inspect_hash(ks,self)
    else
      map { |x| x.mongo_inspect }.join(",")
    end
  end
  def contains_array?
    any? { |x| x.kind_of?(Array) }
  end
  def contains_all_hashes?
    all? { |x| x.kind_of?(Hash) || x.kind_of?(OrderedHash) }
  end
end

module HashMod
  def mongo_inspect
    mongo_inspect_hash(keys,[self])
  end
end
class Hash
  include HashMod
end
class OrderedHash
  include HashMod
end

