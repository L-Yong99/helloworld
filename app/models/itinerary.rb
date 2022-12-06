class Itinerary < ApplicationRecord
  geocoded_by :address
  after_validation :geocode, if: :will_save_change_to_address?

  has_many :lists, dependent: :destroy
  belongs_to :user
  has_many :users_itineraries
  has_many :activities, dependent: :destroy
  has_many :places, through: :activities
  has_many_attached :photos

  validates :start_date, :end_date, :title, presence: true


  def get_dates_array(id)
    itinerary = Itinerary.find(id)
    start_date = itinerary.start_date
    end_date = itinerary.end_date
    date_arr = (start_date..end_date).to_a
  end
end
