class Itinerary < ApplicationRecord
  belongs_to :user
  has_many :users_itineraries
  has_many :activities
  has_many :places, through: :activities
end
