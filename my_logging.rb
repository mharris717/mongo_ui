# Dir["log/*.log"].each { |x| `rm #{x}` }

class MyLog
  attr_accessor :name
  include FromHash
  fattr(:filename) { "log/#{name}.log" }
  def log(strs)
    #strs = [strs] unless strs.kind_of?(Array)
    #strs = [name] + strs if name == 'all'
    strs = strs.flatten
    str = strs.map { |x| x.kind_of?(String) ? x : x.inspect }.join(" ")
    File.append(filename,"#{Time.now} | #{str}\n")
  end
end

def log(name,*strs)
  # MyLog.new(:name => name).log(strs)
  # MyLog.new(:name => 'all').log([name]+[strs])
end