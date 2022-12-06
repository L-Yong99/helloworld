class Place < ApplicationRecord
  has_many :activities

  def get_geojson(places, itinerary, dates)
    geodata = {type: "FeatureCollection"}
    features = places.map do |place|
      {
        type: "Feature",
        geometry: {
            type: "Point",
            coordinates: [place.lng, place.lat]
        },
        properties: {
            name: place.name,
            description: place.description,
            category: place.category,
            rating: place.rating,
            booking: place.booking,
            lat: place.lat,
            lng: place.lng,
            image: place.image,
            country: place.country,
            review: place.review_summary,
            placeId: place.id,
            defaultIcon: "default_#{place.category}",
            activeIcon: "active_#{place.category}",
            info_window: ac.render_to_string(partial: "info_window", locals: {place: place, dates: dates, itineraryId: itinerary.id})
        },

      }
    end
    geodata[:features] = features
  end
end
