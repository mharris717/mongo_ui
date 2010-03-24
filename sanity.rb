def assert_mongo_value(str,exp)
  res = mongo_value(str)
  if res != exp
    raise "Expected #{exp.inspect}, got #{res.inspect}"
  end
end

assert_mongo_value "[1,2,3]",[1,2,3]
assert_mongo_value "{1 => 2}", {1 => 2}