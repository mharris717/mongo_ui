def assert_mongo_value(str,exp)
  res = mongo_value(str)
  if res != exp
    raise "Expected #{exp.inspect}, got #{res.inspect}"
  end
end

def assert_equal(a,b)
  puts 'asserting'
  raise "#{a.inspect} != #{b.inspect}" unless a == b
end

Dir["sanity/*.rb"].each { |x| require x }