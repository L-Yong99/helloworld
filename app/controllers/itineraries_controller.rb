class ItinerariesController < ApplicationController
  def index
  end

  def show
  end

  def new
    @itinerary = Itinerary.new
  end

  def create
    date_range = params[:date]
    start_date_arr = date_range.split(' ')[0].split('-')
    end_date_arr = date_range.split(' ')[2].split('-')
    start_date = Date.new(start_date_arr[0].to_i,start_date_arr[1].to_i,start_date_arr[2].to_i)
    end_date = Date.new(end_date_arr[0].to_i,end_date_arr[1].to_i,end_date_arr[2].to_i)
    travel_days = (end_date - start_date).to_i + 1
    address = params[:address].downcase
    itinerary = Itinerary.new(start_date:start_date,end_date:end_date,address:address,travel_days:travel_days)
    itinerary.user = current_user
    itinerary.save
    redirect_to plan_itinerary_path(itinerary)
  end

  def destroy
    @itinerary = Itinerary.find(params[:id])
    @itinerart.destroy

    redirect_to dashboard_itineraries_path, status: :see_other
  end

  def plan
    @itinerary = Itinerary.find(params[:id])
    @center = @itinerary.geocode
    start_date = @itinerary.start_date
    end_date = @itinerary.end_date
    date_arr = (start_date..end_date).to_a
    # Query for country
    country = @itinerary.address
    country.capitalize!
    @places = Place.where(country: country)
    geodata = {type: "FeatureCollection"}
    features = @places.map do |place|
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
            info_window: render_to_string(partial: "info_window", locals: {place: place, dates: date_arr})
        },

      }
    end
    geodata[:features] = features
    @geodata_json = geodata.to_json
  end

  def complete
  end

  def summary
  end

  def dashboard
  end

  def search
  end
end
