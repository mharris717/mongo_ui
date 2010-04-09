module A
  def a
    17
  end
end

class Fox
  include A
end

module A
  def b
    18
  end
end

assert_equal Fox.new.b, 18