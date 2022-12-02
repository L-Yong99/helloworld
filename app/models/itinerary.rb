class Itinerary < ApplicationRecord
  geocoded_by :address
  after_validation :geocode, if: :will_save_change_to_address?

  belongs_to :user
  has_many :users_itineraries
  has_many :activities
  has_many :places, through: :activities
  has_many_attached :photos

  validates :start_date, :end_date, :title, presence: true
end
