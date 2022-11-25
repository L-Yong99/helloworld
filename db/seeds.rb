
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

# require_relative "sg_food"
# require_relative "sg_food_detail"
# # Place.destroy_all

# # # Get Singapore (Foods)
# # require "uri"
# # require "net/http"

# API_KEY = "AIzaSyC08TpSpRDX03GSMMIdx_2lInLF4QpxfDk"
# # lat = 1.3521
# # lng = 103.8198
# # radius = 100000
# # type = "restaurant"

# # url = URI("https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{lat}%2C#{lng}&radius=#{radius}&type=#{type}&key=#{API_KEY}")

# # https = Net::HTTP.new(url.host, url.port)
# # https.use_ssl = true

# # request = Net::HTTP::Get.new(url)

# # response = https.request(request)
# # puts response.read_body

# def get_place_detail(place_id)
#   url = URI("https://maps.googleapis.com/maps/api/place/details/json?place_id=#{place_id}&fields=name%2Crating%2Creviews%2Ceditorial_summary&key=#{API_KEY}")

#   https = Net::HTTP.new(url.host, url.port)
#   https.use_ssl = true

#   request = Net::HTTP::Get.new(url)

#   response = https.request(request)
#   response.read_body
# end

# def get_photo_detail(photo_ref)
#   url = URI("https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=#{photo_ref}&key=#{API_KEY}")

#   https = Net::HTTP.new(url.host, url.port)
#   https.use_ssl = true

#   request = Net::HTTP::Get.new(url)

#   response = https.request(request)
#   response.read_body
# end


# sg_food = get_food
# sg_food_sym = sg_food.deep_symbolize_keys[:results]
# # puts sg_food_sym.count
# # pp = sg_food_sym[0][:photos]
# # p pp[0][:photo_reference]

# # details = []
# # photos = []
# # sg_food_sym.each do |result|
# #   # details << JSON.parse(get_place_detail(result[:place_id])).deep_symbolize_keys[:result]
# #   photos << get_photo_detail(result[:photos][0][:photo_reference])
# #   p photos
# #   return
# # end
# # # p photos

user1 = User.create!(
  email: "malcolm@gmail.com",
  first_name: "Malcolm",
  last_name: "The Rich",
  gender: "male",
  country: "Mexican",
  password: "123456"
)

itinerary1 = Itinerary.create!(
  title: "fun camping",
  start_date: Date.new(2022,11,27),
  end_date: Date.new(2022,11,29),
  travel_days: 3,
  phase: "planning",
  address: "Japan",
  user: user1
)

itinerary2 = Itinerary.create!(
  title: "The 3 Days Magical Gateway",
  start_date: Date.new(2022,11,27),
  end_date: Date.new(2022,11,29),
  travel_days: 3,
  phase: "planning",
  address: "Mexico",
  user: user1
)
itinerary3 = Itinerary.create!(
  title: "Road Trip Toad Lips",
  start_date: Date.new(2022,11,27),
  end_date: Date.new(2022,11,29),
  travel_days: 3,
  phase: "planning",
  address: "Malaysia",
  user: user1
)
itinerary4 = Itinerary.create!(
  title: "School",
  start_date: Date.new(2022,11,27),
  end_date: Date.new(2022,11,29),
  travel_days: 3,
  phase: "planning",
  address: "Cambodia",
  user: user1
)
itinerary5 = Itinerary.create!(
  title: "Soul Searching",
  start_date: Date.new(2022,11,27),
  end_date: Date.new(2022,11,29),
  travel_days: 3,
  phase: "planning",
  address: "Laos",
  user: user1
)



# sg_food_detail_sym = get_food_detail
# p sg_food_detail_sym[0]

require_relative "open_food"
require_relative "open_food_hash"
## Get place by radius funtion (returns a Geo JSON format)
def get_places_by_radius(attr ={})
  lat = attr[:lat]
  lng = attr[:lng]
  radius = attr[:radius]
  kind = attr[:kind]
  limit = attr[:limit]

  url = URI("https://opentripmap-places-v1.p.rapidapi.com/en/places/radius?radius=#{radius}&lon=#{lng}&lat=#{lat}&kinds=#{kind}&rate=3&limit=#{limit}")

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

food_data_json = get_open_food # get from our file

# convert json to hash
def json_to_hash(json_data)
  data_hash = JSON.parse(json_data).deep_symbolize_keys
end

food_data_hash = json_to_hash(food_data_json)

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

food_data_hash_filter = filter_data(food_data_hash)

#  p food_data_hash_filter

# food_data_hash_filter[:features].each_with_index do |feature,i|
# p feature[:properties][:name]
# end

# a =  food_data_hash_filter[:features].slice(1,3)

# def add_details_to_place(data_hash_filter)
#   data_hash_filter[:features].each_with_index do |feature,i|
#     url = URI("https://opentripmap-places-v1.p.rapidapi.com/en/places/xid/#{feature[:properties][:xid]}")

#     http = Net::HTTP.new(url.host, url.port)
#     http.use_ssl = true
#     http.verify_mode = OpenSSL::SSL::VERIFY_NONE

#     request = Net::HTTP::Get.new(url)
#     request["X-RapidAPI-Key"] = 'd8df50061amsh1ec3135162e3badp113398jsn639c7ffee287'
#     request["X-RapidAPI-Host"] = 'opentripmap-places-v1.p.rapidapi.com'

#     response = http.request(request)
#     # p response.read_body

#     hash = json_to_hash(response.read_body)
#     # p hash
#     country = hash[:address][:country]
#     text = hash[:wikipedia_extracts][:text]
#     image = hash[:preview][:source]

#     data_hash_filter[:features][i][:properties][:country] = country
#     data_hash_filter[:features][i][:properties][:text] = text
#     data_hash_filter[:features][i][:properties][:image] = image
#   end
#   return data_hash_filter
# end

# food_data_hash_filter = add_details_to_place(food_data_hash_filter)


food_data_hash_filter = get_open_food_hash

# def change_property(data_hash_filter,key,value)
#   key_sym = key.parameterize.underscore.to_sym
#   puts key_sym.class
#   data_hash_filter[:features].each_with_index do |feature,i|
#     data_hash_filter[:features][i][:properties][key_sym] = value
#   end
#   return data_hash_filter
# end

# food_data_hash_filter = change_property(food_data_hash_filter,"kinds","foods")


p food_data_hash_filter


food_data_hash_filter[:features].each do |feature|
  puts "hey"
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
