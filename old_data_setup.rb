    puts "#{UserCollection.all.size} UserCollections"
    # UserCollection.all.each { |x| x.destroy }
    # GroupedUserCollection.all.each { |x| x.destroy }

    # UserCollection.create!(:coll_name => 'PlayersbyValue', :base_coll_name => 'players', :sort_conditions => [['value',:desc]])
    # UserCollection.create!(:coll_name => 'PandaPlayers', :base_coll_name => 'players', :filter_conditions => {:team => 'Panda'})
    UserCollection.create!(:coll_name => 'available', :base_coll_name => 'players', :filter_conditions => {:team => nil}, :sort_conditions => [['rank',:asc]])
    UserCollection.create!(:coll_name => 'pl', :base_coll_name => 'players', :sort_conditions => [['rank',:asc]])
    UserCollection.create!(:coll_name => 'tp', :base_coll_name => 'team_pos')
    # UserCollection.create!(:coll_name => 'panda', :base_coll_name => 'players', :filter_conditions => {:team => 'panda'})
    # UserCollection.create!(:coll_name => 'recent', :base_coll_name => 'players', :filter_conditions => {:updated_at => {'$gt' => 30.minutes.ago}})

    #GroupedUserCollection.new(:coll_name => 'teams', :base_coll_name => 'players', :group_key => 'team', :sum_field => 'value').save! 
    # GroupedUserCollection.new(:coll_name => 'teams2', :base_coll_name => 'players', :group_key => 'team', :sum_fields => ['hr','rbi']).save!


puts db.collection('bets').find.to_a.size
puts db.collection('bs').find.to_a.size
db.collection('bets').find.each do |x|
  puts x.inspect
end

#UserCollection.create!(:coll_name => 'mefoo', :base_coll_name => 'foo')
# raise UserCollection.all.map { |x| "#{x.coll_name} #{x.base_coll_name}" }.inspect