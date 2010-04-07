# db.collection('players').tap do |c|
#   c.remove
#   c.find_or_create(:name => 'Albert Pujols', :position => '1B', :value => 62)
#   c.find_or_create(:name => 'David Wright', :position => '3B', :value => 55, :team => 'Panda')
#   c.find_or_create(:name => 'Roy Halladay', :position => 'SP', :value => 45)
#   c.find_or_create(:name => 'Ryan Zimmerman', :position => '3B', :value => 27)
#   c.find_or_create(:name => 'Michael Bourn', :position => 'OF', :value => 27)
#   c.find_or_create(:name => 'Hanley Ramirez', :position => 'SS', :value => 65)
#   (2..10).each do |i|
#     c.find_or_create(:name => "Albert Pujols#{i}", :position => "1B", :value => 62)
#     c.find_or_create(:name => "David Wright#{i}", :position => "3B", :value => 55, :team => "Panda")
#     c.find_or_create(:name => "Roy Halladay#{i}", :position => "SP", :value => 45)
#     c.find_or_create(:name => "Ryan Zimmerman#{i}", :position => "3B", :value => 27)
#     c.find_or_create(:name => "Michael Bourn#{i}", :position => "OF", :value => 27)
#     c.find_or_create(:name => "Hanley Ramirez#{i}", :position => 'SS', :value => 65)
#   end
# end

def load_players!
  require 'fastercsv'
  i = 0
  c = db.collection('players')
  #c.remove
  # FasterCSV.foreach("pbrl.csv", :headers => true) do |row|
  #   player = c.find_or_create(:name => row['PLAYER'], :position => row['POS'], :value => row['$$$'].to_s[1..-1].to_i, :team => row['Winner'], :bid => row['Winner $'].to_i, :rank => (i+=1), 
  #   :hr => row['HR'].to_i, :rbi => row['RBI'].to_i, :avg => row['AVG'].to_f, :pa => row['PA'].to_i, :sb => row['SB'].to_i,
  #   :w => row['W'].to_i, :sv => row['SV'].to_i, :ip => row['IP'].to_i, :era => row['ERA'].to_f, :whip => row['WHIP'].to_f, :mlb_team => row['TEAM'])
  #   #return if i >= 2000
  # end
  
end

def set_profit!
  c = db.collection('players')
  c.find.each do |player|
    player['profit'] = player['value'] - player['bid'] if player['value'] && player['bid']
    c.save(player)
  end
end

def set_pos_list!
  c = db.collection('players')
  c.find.each do |player|
    player['positions'] = player['position'].split(",")
    c.save(player)
  end
end

def fix_data!
  c = db.collection('players')
  c.find.each do |player|
    player.delete('updated at')
    c.save(player)
  end
end

def fix_dups
  c = db.collection('players')
  c.find(:team => /./).each do |p|
    c.find(:name => p['name']).each do |newp|
      if newp['team'].blank?
       c.remove(newp)
       puts "removing #{newp.inspect}" 
      end
    end
  end
end
    
if db.collection('bets').find.count == 0
  c = db.collection('bets')
  c.save(:home => 'NYM', :away => 'FLA', :line => [{:odds => '+115', :amount => 200}])
end
# UserCollection.create!(:coll_name => 'bs', :base_coll_name => 'bets')

#load_players!
#set_pos_list!
# fix_data!

# d = db.collection('players').find_one
# d['x'] ||= 'x'
# db.collection('players').save(d)

if false
  
  db.collections.reject { |x| x.name == 'players' }.each { |x| x.drop }

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
end