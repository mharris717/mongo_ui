def assert_mongo_value(str,exp)
  res = mongo_value(str)
  if res != exp
    raise "Expected #{exp.inspect}, got #{res.inspect}"
  end
end

def assert_equal(a,b)
  puts 'asserting'
  raise "#{a.inspect} != #{b.inspect}" unless a == b
end

assert_mongo_value "[1,2,3]",[1,2,3]
assert_mongo_value "{1 => 2}", {1 => 2}

a = {1 => 2, 3 => 4}.map_sorted_by_key_asc { |k,v| v }
assert_equal a,[2,4]

# assert_equal GroupedUserCollection.all.size, 0

if false
# --------------
class Media
  include MongoMapper::EmbeddedDocument
  key :file, String
end
 
class Video < Media
  key :length, Integer
end
 
class Image < Media
  key :width, Integer
  key :height, Integer
end
 
class Music < Media
  key :bitrate, String
end
 
class Catalog
  include MongoMapper::Document
  
  many :medias, :polymorphic => true
end
 
catalog = Catalog.new
catalog.medias = [
  Video.new("file" => "video.mpg", "length" => 3600),
  Music.new("file" => "music.mp3", "bitrate" => "128kbps"),
  Image.new("file" => "image.png", "width" => 800, "height" => 600)
]
catalog.save #=> true
 
from_db = Catalog.find(catalog.id)
from_db.medias.size #=> 3
from_db.medias[0].file #=> "video.mpg"
from_db.medias[0].length #=> 3600
from_db.medias[1].file #=> "music.mp3"
from_db.medias[1].bitrate #=> "128kbps"
from_db.medias[2].file #=> "image.png"
from_db.medias[2].width #=> 800
from_db.medias[2].height #=> 600
assert_equal from_db.medias.map { |x| x.class },[Video,Music,Image]




#-----
class Vehicle
  include MongoMapper::EmbeddedDocument
  key :name
end

class Car < Vehicle
  key :color
end

class Bike < Vehicle
  key :bike_lock
end

class Garage
  include MongoMapper::Document
  many :vehicles, :polymorphic => true
end


g = Garage.new
g.vehicles = [Bike.new(:name => 'A', :bike_lock => true), Car.new(:name => 'B', :color => 'Red')]
g.save!

puts "BEFORE A"
g = Garage.find(g.id)
cs = g.vehicles.map { |x| x.class }
assert_equal [Bike,Car],cs

# puts "BEFORE B"
# g = Garage.all.first
# #raise g.inspect
# cs = g.vehicles.map { |x| x.class }
# assert_equal [Bike,Car],cs
end