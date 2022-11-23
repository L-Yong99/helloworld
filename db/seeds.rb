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

Itinerary.destroy_all
User.destroy_all

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
