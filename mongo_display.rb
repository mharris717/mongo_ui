def mongo_value(v)
  if v.kind_of?(Time)
    v
  elsif v[0..0] == '['
    #v[1...-1].split(",").map { |x| x.tmo }
    eval(v).map { |x| x.tmo }
  elsif v[0..0] == '{'
    eval(v).map_key { |x| x.tmo }.map_value { |x| x.tmo }
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

class Array
  def mongo_inspect
    if contains_array?
      "<ul>" + map { |x| "<li>#{x.mongo_inspect}</li>" }.join("") + "</ul>"
    else
      map { |x| x.mongo_inspect }.join(",")
    end
  end
  def contains_array?
    any? { |x| x.kind_of?(Array) }
  end
end

class Hash
  def mongo_inspect
    "<ul>" + map { |k,v| "<li>#{k.mongo_inspect}: #{v.mongo_inspect}</li>" }.join("") + "</ul>"
  end
end
