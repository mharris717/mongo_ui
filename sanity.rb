def assert_mongo_value(str,exp)
  res = mongo_value(str)
  if res != exp
    raise "Expected #{exp.inspect}, got #{res.inspect}"
  end
end

def assert_equal(a,b)
  raise "#{a.inspect} != #{b.inspect}" unless a == b
end

assert_mongo_value "[1,2,3]",[1,2,3]
assert_mongo_value "{1 => 2}", {1 => 2}

a = {1 => 2, 3 => 4}.map_sorted_by_key_asc { |k,v| v }
assert_equal a,[2,4]

assert_equal GroupedUserCollection.all.size, 1