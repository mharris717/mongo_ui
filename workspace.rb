class Workspace
  class << self
    fattr(:instance) { new }
  end
  def colls
    #res = db.collections.reject { |x| x.name == 'system.indexes' || x.name =~ /user_/ }
    res = UserCollection.to_colls
    # u = UserCollection.find_one(:coll_name => 'recent') 
    #  u.filter_conditions = {:updated_at => {'$gt' => 30.minutes.ago}}
    #  u.save!
    #res += GroupedUserCollection.to_colls
    # res << TeamPosCollection.new
    #raise res.size.to_s
    # res << BetTable.new
    res
  end  
  def get_coll(n)
    colls.find { |x| x.name == n }
  end
end