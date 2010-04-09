def create_bets!
  c = db.collection('raw_bets')
  sites = %w(Pinnacle Matchbook)
  odds = %w(+115 -125)
  amounts = [200,100,300,nil]
  rand_line = lambda { {:site => sites.rand, :odds => odds.rand, :amount => amounts.rand} }
  5.times { c.save(:home => 'COL', :away => 'LAD') }
  15.times { c.save(:home => 'NYM', :away => 'FLA', :line => [rand_line[], rand_line[]]) }
  
end
  
def delete_collections!
  db.collections.reject { |x| x.name == 'players' }.each { |x| x.drop }
end

def create_user_collections!
  UserCollection.create!(:coll_name => "bets", :base_coll_name => 'bet_table')
end

delete_collections!
create_bets!
create_user_collections!





    

