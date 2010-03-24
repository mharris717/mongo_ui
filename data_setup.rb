db.collection('players').tap do |c|
  c.remove
  c.find_or_create(:name => 'Albert Pujols', :position => '1B', :value => 62)
  c.find_or_create(:name => 'David Wright', :position => '3B', :value => 55, :team => 'Panda')
  c.find_or_create(:name => 'Roy Halladay', :position => 'SP', :value => 45)
  c.find_or_create(:name => 'Ryan Zimmerman', :position => '3B', :value => 27)
  c.find_or_create(:name => 'Michael Bourn', :position => 'OF', :value => 27)
  c.find_or_create(:name => 'Hanley Ramirez', :position => 'SS', :value => 65)
  (2..10).each do |i|
    c.find_or_create(:name => "Albert Pujols#{i}", :position => "1B", :value => 62)
    c.find_or_create(:name => "David Wright#{i}", :position => "3B", :value => 55, :team => "Panda")
    c.find_or_create(:name => "Roy Halladay#{i}", :position => "SP", :value => 45)
    c.find_or_create(:name => "Ryan Zimmerman#{i}", :position => "3B", :value => 27)
    c.find_or_create(:name => "Michael Bourn#{i}", :position => "OF", :value => 27)
    c.find_or_create(:name => "Hanley Ramirez#{i}", :position => 'SS', :value => 65)
  end
end
