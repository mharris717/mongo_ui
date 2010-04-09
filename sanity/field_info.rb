def fake_bets; db.collection('fake_bets'); end
def make_fake_bets!
  fake_bets.save(:line => [{:odds => '+115', :amount => 200}])  
  fake_bets.save(:home => 'FLA')
end

make_fake_bets!

fi = FieldInfo.new(:field => 'line', :coll => fake_bets, :row => fake_bets.find_one('line.odds' => '+115'))
assert_equal fi.all_hash_keys, ['amount','odds']

fi = FieldInfo.new(:field => 'line', :coll => fake_bets, :row => fake_bets.find_one(:home => 'FLA'))
assert_equal fi.all_hash_keys, ['amount','odds']

