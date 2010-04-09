def mongo_value(v)
  puts "mongo_value #{v.inspect}"
  if v.kind_of?(Time)
    v
  elsif v.kind_of?(String)
    if v[0..0] == '['
      #v[1...-1].split(",").map { |x| x.tmo }
      eval(v).map { |x| mongo_value(x.tmo) }.select { |x| x.present? }.tap { |x| puts "mv arr #{x.inspect}"}
    elsif v[0..0] == '{'
      r = eval(v).map_key { |x| x.tmo }.map_value { |x| mongo_value(x.tmo) }.without_blank_values
      puts "mongo_value hash res #{r.inspect}"
      r.empty? ? nil : r
    elsif v.date?
      v.to_time
    else
      v.tmo
    end
  elsif v.kind_of?(Array)
    v.select { |x| x.present? }
  elsif v.kind_of?(Hash)
    v.without_blank_values
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

require 'parsedate'
class Time
  def self.parsedate(str)
    args = ParseDate.parsedate(str)
    local(*args)
  end
end

class String
  def num?
    size > 0 && self =~ /^[\d\.]*$/
  end
  def date?
    !!((self =~ /\/.*\//) && Time.parsedate(self))
  rescue
    return false
  end
  def to_time
    Time.parsedate(self)
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

# -----------

class Array
  def all_hash_keys
    return [] unless contains_all_hashes?
    map { |x| x.keys }.flatten.uniq
  end
end

module HashMod
  def all_hash_keys
    keys
  end
end

class Object
  def all_hash_keys
    []
  end
end

