# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
require "uri"
require "net/http"

require_relative "sg_food"
require_relative "sg_food_detail"
# Place.destroy_all

# # Get Singapore (Foods)
# require "uri"
# require "net/http"

API_KEY = "AIzaSyC08TpSpRDX03GSMMIdx_2lInLF4QpxfDk"
# lat = 1.3521
# lng = 103.8198
# radius = 100000
# type = "restaurant"

# url = URI("https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{lat}%2C#{lng}&radius=#{radius}&type=#{type}&key=#{API_KEY}")

# https = Net::HTTP.new(url.host, url.port)
# https.use_ssl = true

# request = Net::HTTP::Get.new(url)

# response = https.request(request)
# puts response.read_body


def get_place_detail(place_id)
  url = URI("https://maps.googleapis.com/maps/api/place/details/json?place_id=#{place_id}&fields=name%2Crating%2Creviews%2Ceditorial_summary&key=#{API_KEY}")

  https = Net::HTTP.new(url.host, url.port)
  https.use_ssl = true

  request = Net::HTTP::Get.new(url)

  response = https.request(request)
  response.read_body
end

def get_photo_detail(photo_ref)
  url = URI("https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=#{photo_ref}&key=#{API_KEY}")

  https = Net::HTTP.new(url.host, url.port)
  https.use_ssl = true

  request = Net::HTTP::Get.new(url)

  response = https.request(request)
  response.read_body
end


sg_food = get_food
sg_food_sym = sg_food.deep_symbolize_keys[:results]
# puts sg_food_sym.count
# pp = sg_food_sym[0][:photos]
# p pp[0][:photo_reference]

# details = []
# photos = []
# sg_food_sym.each do |result|
#   # details << JSON.parse(get_place_detail(result[:place_id])).deep_symbolize_keys[:result]
#   photos << get_photo_detail(result[:photos][0][:photo_reference])
#   p photos
#   return
# end
# # p photos


sg_food_detail_sym = get_food_detail
p sg_food_detail_sym[0]
