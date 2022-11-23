class ItinerariesController < ApplicationController
  def index
  end

  def show
  end

  def new
  end

  def create
  end

  def destroy
  end

  def plan
    @itineraries = Itinerary.all
    @markers = @itineraries.geocoded.map do |itinerary|
      {
        lat: itinerary.latitude,
        lng: itinerary.longitude
      }
    end
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
