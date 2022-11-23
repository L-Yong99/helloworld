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
  end

  def plan
    @itinerary = Itinerary.find(params[:id])
    @center = @itinerary.geocode

    # Query for country
    country = @itinerary.address
    country.capitalize!
    @places = Place.where(country: country)
    geodata = {type: "FeatureCollection"}
    features = @places.map do |place|
      f = {
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
        }
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
