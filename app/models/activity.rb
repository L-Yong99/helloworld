class Activity < ApplicationRecord
  belongs_to :place
  belongs_to :itinerary
  has_many :reviews, dependent: :destroy
  has_many :users
end
