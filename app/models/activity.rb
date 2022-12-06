class Activity < ApplicationRecord
  belongs_to :place
  belongs_to :itinerary
  has_many :reviews, dependent: :destroy
  has_many :users

  def self.activity_id_array(itinerary)
    activities = Activity.where(itinerary: itinerary)
    activities_id = activities.map {|activity| activity.place.id}
  end
end
