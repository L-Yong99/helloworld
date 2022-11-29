# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
require 'uri'
require 'net/http'
require 'openssl'

puts "Start seeding......"

puts "seeding users..."
user1 = User.create!(
  email: "malcolm@gmail.com",
  first_name: "Malcolm",
  last_name: "The Rich",
  gender: "male",
  country: "Mexican",
  password: "123456"
)

user2 = User.create!(
  email: "lincoln@gmail.com",
  first_name: "lincoln",
  last_name: "flora",
  gender: "female",
  country: "japan",
  password: "123456"
)

puts "seeding itinieraries..."


def get_photo_ref(country)
  require "uri"
  require "net/http"

  url = URI("https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=#{country}&inputtype=textquery&fields=photos&key=AIzaSyCVNGTJoSPEQ-WO0j-irTq5KwIkhB5uNco")

  https = Net::HTTP.new(url.host, url.port)
  https.use_ssl = true

  request = Net::HTTP::Get.new(url)

  response = https.request(request)
  response.read_body
end

def json_to_hash(json_data)
  data_hash = JSON.parse(json_data).deep_symbolize_keys
end


def get_photo_address_all(country)
  photo_ref_json = get_photo_ref(country)
  data_hash = json_to_hash(photo_ref_json)
  height = data_hash[:candidates][0][:photos][0][:height]
  width = data_hash[:candidates][0][:photos][0][:width]
  ref = data_hash[:candidates][0][:photos][0][:photo_reference]
  return "https://maps.googleapis.com/maps/api/place/photo?maxwidth=#{width}&maxheight=#{height}&photo_reference=#{ref}&key=AIzaSyCVNGTJoSPEQ-WO0j-irTq5KwIkhB5uNco"
end

# image_add = get_photo_address_all("laos")
# puts image_add



itinerary1 = Itinerary.create!(
  title: "3 days fun camping in Japan",
  start_date: Date.new(2022,11,27),
  end_date: Date.new(2022,11,29),
  travel_days: 3,
  phase: "in plan",
  image: get_photo_address_all("japan"),
  user: user1,
  rating: 5,
  vote:5500,
  address: "japan"
)

itinerary2 = Itinerary.create!(
  title: "The 3 Days Magical Gateway",
  start_date: Date.new(2022,11,27),
  end_date: Date.new(2022,11,29),
  travel_days: 3,
  phase: "in plan",
  image: get_photo_address_all("mexico"),
  user: user1,
  rating: 3,
  vote:200,
  address: "mexico"
)
itinerary3 = Itinerary.create!(
  title: "Road Trip Toad Lips",
  start_date: Date.new(2022,11,27),
  end_date: Date.new(2022,11,29),
  travel_days: 3,
  phase: "in plan",
  image: get_photo_address_all("malaysia"),
  user: user1,
  rating: 2,
  vote:20,
  address: "malaysia"
)
itinerary4 = Itinerary.create!(
  title: "School",
  start_date: Date.new(2022,11,27),
  end_date: Date.new(2022,11,29),
  travel_days: 3,
  phase: "in plan",
  image: get_photo_address_all("cambodia"),
  user: user1,
  rating: 3,
  vote:200,
  address: "cambodia"
)
itinerary5 = Itinerary.create!(
  title: "4 days in Soul Searching",
  start_date: Date.new(2022,11,22),
  end_date: Date.new(2022,11,25),
  travel_days: 4,
  phase: "in plan",
  image: get_photo_address_all("korea"),
  user: user1,
  rating: 5,
  vote:4000,
  address: "korea"
)

itinerary6 = Itinerary.create!(
  title: "7 days in New Zealand",
  start_date: Date.new(2022,11,8),
  end_date: Date.new(2022,11,14),
  travel_days: 3,
  phase: "in plan",
  image: get_photo_address_all("laos"),
  user: user1,
  rating: 5,
  vote:3000,
  address: "laos"
)

itinerary7 = Itinerary.create!(
  title: "5 days in Spain",
  start_date: Date.new(2022,11,11),
  end_date: Date.new(2022,11,15),
  travel_days: 5,
  phase: "completed",
  image: get_photo_address_all("spain"),
  user: user1,
  rating: 5,
  vote:4000,
  address: "spain"
)

itinerary8 = Itinerary.create!(
  title: "3 days in Iceland",
  start_date: Date.new(2022,11,11),
  end_date: Date.new(2022,11,13),
  travel_days: 3,
  phase: "completed",
  image: get_photo_address_all("iceland"),
  address: "iceland",
  user: user1,
  rating: 5,
  vote:8000,
)

itinerary9 = Itinerary.create!(
  title: "10 days in Japan",
  start_date: Date.new(2022,11,10),
  end_date: Date.new(2022,11,20),
  travel_days: 10,
  phase: "require review",
  image: get_photo_address_all("japan"),
  address: "japan",
  user: user1,
  rating: 5,
  vote:8000,
)


# sg_food_detail_sym = get_food_detail
# p sg_food_detail_sym[0]

# require_relative "open_food"
# require_relative "open_food_hash"
## Get place by radius funtion (returns a Geo JSON format)

puts "seeding places..."

def get_places_by_radius(attr ={})
  lat = attr[:lat]
  lng = attr[:lng]
  radius = attr[:radius]
  kinds = attr[:kinds]
  limit = attr[:limit]

  url = URI("https://opentripmap-places-v1.p.rapidapi.com/en/places/radius?radius=#{radius}&lon=#{lng}&lat=#{lat}&kinds=#{kinds}&rate=3&limit=#{limit}")

  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  request = Net::HTTP::Get.new(url)
  request["X-RapidAPI-Key"] = 'd8df50061amsh1ec3135162e3badp113398jsn639c7ffee287'
  request["X-RapidAPI-Host"] = 'opentripmap-places-v1.p.rapidapi.com'

  response = http.request(request)
  response.read_body
end


# food_data =  get_places_by_radius(lat:1.3521,lng:103.8198,radius:100000,kind:"foods",limit:30)

# food_data_json = get_open_food # get from our file

# food_data_hash = json_to_hash(food_data_json)

# Filter empty name string and duplicates
def filter_data(data_hash)
  unique_container = []
  data_hash_filter = {types: "FeatureCollection"}
  features = []
    data_hash[:features].each_with_index do |feature,i|
      # p feature[:properties][:name]
      unless feature[:properties][:name].empty?
        unless unique_container.include?(feature[:properties][:name])
          features << feature
          unique_container << feature[:properties][:name]
        end
      end
    end
  # p  data_hash_filter
  data_hash_filter[:features] = features
  return data_hash_filter
end

# food_data_hash_filter = filter_data(food_data_hash)

#  p food_data_hash_filter

# food_data_hash_filter[:features].each_with_index do |feature,i|
# p feature[:properties][:name]
# end

# a =  food_data_hash_filter[:features].slice(1,3)

def add_details_to_place(data_hash_filter)
  data_hash_filter[:features].each_with_index do |feature,i|
    url = URI("https://opentripmap-places-v1.p.rapidapi.com/en/places/xid/#{feature[:properties][:xid]}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["X-RapidAPI-Key"] = 'd8df50061amsh1ec3135162e3badp113398jsn639c7ffee287'
    request["X-RapidAPI-Host"] = 'opentripmap-places-v1.p.rapidapi.com'

    response = http.request(request)
    # p response.read_body

    hash = json_to_hash(response.read_body)
    # p hash
    country = hash[:address][:country]
    text = hash[:wikipedia_extracts][:text]
    image = hash[:preview][:source]

    data_hash_filter[:features][i][:properties][:country] = country
    data_hash_filter[:features][i][:properties][:text] = text
    data_hash_filter[:features][i][:properties][:image] = image
  end
  return data_hash_filter
end

# food_data_hash_filter = add_details_to_place(food_data_hash_filter)




def change_property(data_hash_filter,key,value)
  key_sym = key.parameterize.underscore.to_sym
  puts key_sym.class
  data_hash_filter[:features].each_with_index do |feature,i|
    data_hash_filter[:features][i][:properties][key_sym] = value
  end
  return data_hash_filter
end

# food_data_hash_filter = change_property(food_data_hash_filter,"kinds","foods")


# p food_data_hash_filter

# Generate hash for seeding (Places)
# data_json =  get_places_by_radius(lat:1.3521,lng:103.8198,radius:100000,kind:"foods",limit:50)
# data_hash = json_to_hash(data_json)
# data_hash_filter = filter_data(data_hash)
# data_hash_filter = add_details_to_place(data_hash_filter)
# data_hash_filter = change_property(data_hash_filter,"kinds","foods")


## ======================================================================================##
def generate_hash_main(place_hash)
  #place hash => {lat:1.3521,lng:103.8198,radius:100000,kind:"foods",limit:50}
  data_json =  get_places_by_radius(place_hash)
  data_hash = json_to_hash(data_json)
  data_hash_filter = filter_data(data_hash)
  data_hash_filter = add_details_to_place(data_hash_filter)
  data_hash_filter = change_property(data_hash_filter,"kinds",place_hash[:kinds])
end

# data_out = generate_hash_main({lat:1.3521,lng:103.8198,radius:100000,kinds:"foods",limit:50})
# data_out = generate_hash_main({lat:1.3521,lng:103.8198,radius:100000,kinds:"interesting_places",limit:50})
# data_out = generate_hash_main({lat:1.3521,lng:103.8198,radius:100000,kinds:"shops",limit:50})
# p data_out


require_relative "open_foods_hash"
require_relative "open_interesting_places_hash"
require_relative "open_shops_hash"

# Food Places create
food_data_hash_filter = get_open_foods_hash
food_data_hash_filter[:features].each do |feature|
  # puts "foods"
  Place.create(
    name: feature[:properties][:name],
    image: feature[:properties][:image],
    description: feature[:properties][:text],
    country: feature[:properties][:country],
    category: feature[:properties][:kinds],
    rating: feature[:properties][:rate],
    lng: feature[:geometry][:coordinates][0],
    lat: feature[:geometry][:coordinates][1],
    booking: [true,false].sample,
  )
end

## Interesting place create
interesting_places_data_hash_filter = get_open_interesting_places_hash
interesting_places_data_hash_filter[:features].each do |feature|
    # puts "interesting_places"
    Place.create(
      name: feature[:properties][:name],
      image: feature[:properties][:image],
      description: feature[:properties][:text],
      country: feature[:properties][:country],
      category: feature[:properties][:kinds],
      rating: feature[:properties][:rate],
      lng: feature[:geometry][:coordinates][0],
      lat: feature[:geometry][:coordinates][1],
      booking: [true,false].sample,
    )
  end

  ## Shops create
shops_data_hash_filter = get_open_shops_hash
shops_data_hash_filter[:features].each do |feature|
    # puts "shops"
    Place.create(
      name: feature[:properties][:name],
      image: feature[:properties][:image],
      description: feature[:properties][:text],
      country: feature[:properties][:country],
      category: feature[:properties][:kinds],
      rating: feature[:properties][:rate],
      lng: feature[:geometry][:coordinates][0],
      lat: feature[:geometry][:coordinates][1],
      booking: false,
    )
  end

  puts "Done seeding..... get back to work!!!!"
