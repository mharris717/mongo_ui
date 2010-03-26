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
  c.remove
  FasterCSV.foreach("nlasl2.csv", :headers => true) do |row|
    c.save(:name => row['PLAYER'], :position => row['POS'], :value => row['$$$'].to_s[1..-1].to_i, :team => row['Winner'], :bid => row['Winner $'].to_i, :rank => (i+=1))
    return if i >= 200
  end
end
load_players!

db.collections.reject { |x| x.name == 'players' }.each { |x| x.drop }

#db.collection('abc').save(:a => [:b,:c], :d => {:e => :f, :g => :h})

# raise db.collection('players').scope_in(:name => [/wright/i,/hanley/i,'Ramirez, Hanley']).find.map { |x| x['name'] }.inspect

puts "#{UserCollection.all.size} UserCollections"
UserCollection.all.each { |x| x.destroy }
GroupedUserCollection.all.each { |x| x.destroy }

# UserCollection.create!(:coll_name => 'PlayersbyValue', :base_coll_name => 'players', :sort_conditions => [['value',:desc]])
# UserCollection.create!(:coll_name => 'PandaPlayers', :base_coll_name => 'players', :filter_conditions => {:team => 'Panda'})
# UserCollection.create!(:coll_name => 'AvailablePlayers', :base_coll_name => 'players', :filter_conditions => {:team => nil})

GroupedUserCollection.new(:coll_name => 'teams', :base_coll_name => 'players', :group_key => 'team', :sum_field => 'value').save! 
GroupedUserCollection.new(:coll_name => 'teams2', :base_coll_name => 'players', :group_key => 'team', :sum_field => 'bid').save! 