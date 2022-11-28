class ItinerariesController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!, only: [:index, :show, :home]

  def home
    @itineraries = Itinerary.order(vote: :desc).limit(6)
  end

  def index
    @itineraries = Itinerary.all
  end

  def show
  end

  def new
    @itinerary = Itinerary.new
  end

  def create
    @navbar = false
    title =  params[:title]
    date_range = params[:date]
    start_date_arr = date_range.split(' ')[0].split('-')
    end_date_arr = date_range.split(' ')[2].split('-')
    start_date = Date.new(start_date_arr[0].to_i,start_date_arr[1].to_i,start_date_arr[2].to_i)
    end_date = Date.new(end_date_arr[0].to_i,end_date_arr[1].to_i,end_date_arr[2].to_i)
    travel_days = (end_date - start_date).to_i + 1
    address = params[:address].downcase
    image = get_photo_address_all(address)
    itinerary = Itinerary.new(title: title,start_date:start_date,end_date:end_date,address:address,travel_days:travel_days, image:image,vote:0,rating:0)
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
    @itinerary_id = params[:id]
    @center = @itinerary.geocode
    start_date = @itinerary.start_date
    end_date = @itinerary.end_date
    date_arr = (start_date..end_date).to_a
    @dates = date_arr
    @activities = Activity.where(itinerary_id: @itinerary.id)
    @activities_id = @activities.map {|activity| activity.place.id}
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
            info_window: render_to_string(partial: "info_window", locals: {place: place, dates: date_arr, itineraryId: @itinerary.id})
        },

      }
    end
    geodata[:features] = features
    @geodata_json = geodata.to_json
  end

  def save
      data_json = params[:data]
      data_hash = JSON.parse(data_json).deep_symbolize_keys
      @itinerary_id = data_hash[:itinerary_id].to_i
      day = data_hash[:day].to_i
      activities_count = Activity.where(day: day, itinerary_id: @itinerary_id).count
      # data_hash[:date] = Date.new(data_hash[:date])
      data_hash[:event_sequence] = activities_count + 1
      place = Place.find(data_hash[:place_id])
      itinerary = Itinerary.find(data_hash[:itinerary_id])
      @activity = Activity.new(data_hash)
      @activity.place = place
      @activity.itinerary = itinerary
      @activity.save
      @activities = Activity.where(itinerary_id: @itinerary_id)
      @dates = (itinerary.start_date..itinerary.end_date).to_a
      respond_to do |format|
      if @activity.save
        # format.html { redirect_to restaurant_path(@restaurant) }
        format.json # Follow the classic Rails flow and look for a create.json view
      else
        # format.html { render "restaurants/show", status: :unprocessable_entity }
        format.json # Follow the classic Rails flow and look for a create.json view
      end
    end
  end

  def delete
    itinerary = Itinerary.find(params[:id])
    @itinerary_id = params[:id]
    @activities = Activity.where(itinerary_id: @itinerary_id)
    @dates = (itinerary.start_date..itinerary.end_date).to_a
    activity_id = params[:data].to_i
    activity = Activity.find(activity_id)
    activities_a = Activity.where(itinerary: itinerary, day: activity.day).where('event_sequence > ?', activity.event_sequence)
    activities_a.each do |a|
      a.event_sequence = a.event_sequence - 1
    end
    respond_to do |format|
      if activity.destroy
      # format.html { redirect_to restaurant_path(@restaurant) }
        format.json # Follow the classic Rails flow and look for a create.json view
      else
      # format.html { render "restaurants/show", status: :unprocessable_entity }
        format.json # Follow the classic Rails flow and look for a create.json view
      end
    end
  end

  def complete
  end

  def summary
    @itinerary = Itinerary.find(params[:id])

  end

  def dashboard
    @myitineraries = Itinerary.where(user:current_user)
    @currentUser = current_user.id
    # raise
  end

  def search
  end


  private

  def get_photo_ref(country)
    require "uri"
    require "net/http"

    url = URI("https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=#{country}&inputtype=textquery&fields=photos&key=#{ENV['GOOGLE_API']}")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Get.new(url)

    response = https.request(request)
    response.read_body
  end

  def json_to_hash(json_data)
    data_hash = JSON.parse(json_data).deep_symbolize_keys
  end


  def get_photo_address_all(country)
    photo_ref_json = get_photo_ref(country)
    data_hash = json_to_hash(photo_ref_json)
    height = data_hash[:candidates][0][:photos][0][:height]
    width = data_hash[:candidates][0][:photos][0][:width]
    ref = data_hash[:candidates][0][:photos][0][:photo_reference]
    return "https://maps.googleapis.com/maps/api/place/photo?maxwidth=#{width}&maxheight=#{height}&photo_reference=#{ref}&key=AIzaSyCVNGTJoSPEQ-WO0j-irTq5KwIkhB5uNco"
  end
end
