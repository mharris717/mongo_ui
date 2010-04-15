def create_bets!
  c = db.collection('raw_bets')
  sites = %w(Pinnacle Matchbook)
  odds = %w(+115 -125)
  amounts = [200,100,300,nil]
  rand_line = lambda { {:site => sites.rand, :odds => odds.rand, :amount => amounts.rand} }
  # 5.times { c.save(:home => 'COL', :away => 'LAD') }
  # 15.times { c.save(:home => 'NYM', :away => 'FLA', :line => [rand_line[], rand_line[]], :home_perc => 40 ) }
  
  ls = []
  ls << {:site => 'Pinnacle', :odds => '-125', :team => 'NYM'}
  ls << {:site => 'Pinnacle', :odds => '+115', :team => 'WAS'}
  ls << {:site => 'Matchbook', :odds => '-121', :team => 'NYM'}
  c.save(:home => 'NYM', :away => 'WAS', :line => ls, :home_perc => 65)
end

def create_people!
  c = db.collection('base_people')
  c.save(:name => 'Mike', :age => 27)
  c.save(:name => 'Lowell', :age => 40)
end
  
def delete_collections!
  db.collections.reject { |x| x.name == 'players' }.each { |x| x.drop }
end

def create_user_collections!
  UserCollection.create!(:coll_name => "bets", :base_coll_name => 'bet_table')
  UserCollection.create!(:coll_name => "people", :base_coll_name => 'base_people')
end

delete_collections!
create_bets!
create_people!
create_user_collections!





    

