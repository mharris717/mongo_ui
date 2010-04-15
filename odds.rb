class Odds
  def self.winloss(w,l)
    new(l/w)
  end
  def self.parse(str,ops)
    ops[:missing_plus] = true
    num = nil
    raise "empty str #{str.class} passed to Pdds.parse" unless str && str.strip != ''
    str = "+#{str}" if ops[:missing_plus] and str =~ /^[\d\.]+$/
    if str.strip =~ /^-\d+$/
      num = 100.0/str[1..-1].to_f
    elsif str.strip =~ /^\+\d+$/
      num = str[1..-1].to_f/100.0
    else
      raise "can't parse #{str}"
    end
    new(num)
  end
  def self.get(o,ops={})
    return parse(o,ops) if o.is_a?(String)
    return new(o) if o.is_a?(Numeric) or o.is_a?(Percent)
    return o if o.is_a?(Odds)
    raise "can't turn #{o} into Odds"
  end
  attr_accessor :rfd
  def initialize(rfd)
    @rfd = rfd
    raise "must be number" unless rfd.is_a?(Numeric)
    raise "can't handle NaN" if rfd.nan?
    raise "can't handle infinity" if rfd.infinite?
    raise "odds can't be 0" if rfd.to_f == 0.0
    @rfd = @rfd.round_dec(5)
    to_s
  end
  def to_s
    res = (self > 1) ? "+"+(self*100.0001).to_i.to_s : "-"+(100/self).to_i.to_s
    res.tap { |x| raise "invalid odds #{x}" unless x =~ /^[\+\-]\d/ }
  end
  def method_missing(sym,*args,&b)
    rfd.send(sym,*args,&b)
  end
  def half_of
    Odds.new((1+rfd)**0.5 - 1.0)
  end
  def ==(x)
    to_s == x.to_s
  end
  #def <=>(x)
  #  rfd <=> x.rfd
  #end
  def perc
    rfd / (rfd + 1)
  end
  def flip
    Odds.new(1.0 / rfd)
  end
end