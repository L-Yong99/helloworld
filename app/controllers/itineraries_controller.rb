class ItinerariesController < ApplicationController
  # skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!, only: [:index, :show, :home]
  before_action :set_itinerary, only: [:show, :destroy, :plan, :update, :summary, :addimage, :review]
  before_action :set_date, only: [:show, :delete, :sort, :summary, :plan, :show]


  def home
    @navbar = "home"
    @itineraries = Itinerary.order(vote: :desc).limit(6)
  end

  def index
    @navbar = "others"
    @itineraries = Itinerary.all
    @completed_itineraries = @itineraries.where(phase: "completed")
  end

  def show
    @navbar = "others"
    @reviews = Review.joins(:activity).where("activities.itinerary_id = ? ", @itinerary.id)
    activities_sequence = Activity.where(itinerary: @itinerary).order(:day).order(:event_sequence)
    @activities_coord = activities_sequence.map { |activity| {name: activity.place.name, lat: activity.place.lat, lng:activity.place.lng} }
    @country = {coord: @itinerary.geocode, name: @itinerary.address}
    @activities = Activity.where(itinerary: @itinerary)
    @activities_completed = @activities.where(status: "updated").limit(5)
  end

  def new
    @navbar = "others"
    @itinerary = Itinerary.new
  end

  def create
    self.Create_or_copy_itinerary
  end

  def destroy
    if @itinerary.user == current_user
      @itinerary.destroy
      redirect_to dashboard_itineraries_path, status: :see_other
    end
  end

  def plan
    @center = @itinerary.geocode
    @activities = Activity.where(itinerary: @itinerary)
    @activities_id = Activity.activity_id_array(@itinerary)
    @places = Place.where(country: @itinerary.address.capitalize!)
    @geodata_json = get_geojson(@places, @itinerary, @dates).to_json
  end

  def update
    unless params[:phase]
      @itinerary.update!(itinerary_params)
      redirect_to summary_itinerary_path(@itinerary)
    end
    case params[:phase]
      when "ongoing"
        @itinerary.update!(phase: params[:phase])
        redirect_to itinerary_activity_path(@itinerary, 1)
      when "require review"
        @itinerary.update!(phase: params[:phase])
        redirect_to summary_itinerary_path(@itinerary)
      when "completed"
        @itinerary.update!(phase: params[:phase])
        redirect_to review_itinerary_path(@itinerary)
      end
  end

  def complete
  end

  def summary
    @navbar = "others"
    @reviews = Review.joins(:activity).where("activities.itinerary_id = ? ", @itinerary.id)
    @activities = Activity.where(itinerary: @itinerary)
    @activities_completed = @activities.where(status: "updated").limit(5)

    ## Get bookings
    @total_require_bookings_count = @activities.joins(:place).where("places.booking = ? ", true).count
    @activities_with_booking = @activities.joins(:place).where("places.booking = ? ", true)
    @activities_with_booking_pending = Activity.where(booking: "pending")

    # Get to do
    @todolist = List.where(itinerary: @itinerary)
    @todolist_count = @todolist.count
  end

  def dashboard
    @navbar = "others"
    @myitineraries = Itinerary.where(user: current_user)
    @inplan_itineraries = @myitineraries.where(phase: "in plan")
    @ongoing_itineraries = @myitineraries.where(phase: "ongoing")
    @review_itineraries = @myitineraries.where(phase: "require review")
    @completed_itineraries = @myitineraries.where(phase: "completed")
  end

  def search
  end

  def review
    @navbar = "others"
  end

  def bookingcheck
    booking_data = JSON.parse(params[:data])
    activity = Activity.find(booking_data[0])
    booking_data[1] == true ? activity.update(booking: 'updated') : activity.update(booking: 'pending')
    respond_to do |format|
      if activity.save
        format.json # Follow the classic Rails flow and look for a create.json view
      end
    end
  end

  def addimage
    @itinerary.photos.attach(params[:photo])
    redirect_to summary_itinerary_path(@itinerary)
  end





  private

  def set_date
    itinerary = Itinerary.find(params[:id])
    @dates = itinerary.get_dates_array(params[:id])
  end

  def set_itinerary
    @itinerary = Itinerary.find(params[:id])
  end

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
            info_window: render_to_string(partial: "info_window", locals: {place: place, dates: dates, itineraryId: itinerary.id})
        },

      }
    end
    geodata[:features] = features
    return geodata
  end

  # For creating new itinerary or creating new copied itinerary
  def Create_or_copy_itinerary
    if params[:data].nil?
      itinerary = Itinerary.new(get_create_itinerary_detail(params))
      itinerary.user = current_user
      itinerary.save
      redirect_to plan_itinerary_path(itinerary)
    else
      copy_itinerary = Itinerary.find(params[:data].to_i)
      itinerary = Itinerary.new(copy_itinerary_details(params, copy_itinerary))
      itinerary.user = current_user
      itinerary.save
      copy_activities_details(params, copy_itinerary, itinerary)
      redirect_to plan_itinerary_path(itinerary)
    end
  end

  def copy_activities_details(params, copy_itinerary, itinerary)
    date_array = get_dates_array_full(params[:date])[2]
    copy_activities = Activity.where(itinerary: copy_itinerary)
    copy_activities.each do |copy_activity|
      copy_activity.place.booking ? booking = "pending" : booking = "none"
      Activity.create(event_sequence: copy_activity.event_sequence, day: copy_activity.day, place: copy_activity.place, itinerary: itinerary, date: date_array[copy_activity.day - 1], status:'pending',booking:booking)
    end
  end

  def copy_itinerary_details(params,copy_itinerary)
    copy_itinerary_address = copy_itinerary.address
    copy_itinerary_image= copy_itinerary.image
    start_date = get_dates_array_full(params[:date])[0]
    end_date = get_dates_array_full(params[:date])[1]
    travel_days = get_travel_days(start_date, end_date)
    {title: params[:title],
    start_date: start_date,
    end_date: end_date,
    travel_days: travel_days,
    address: copy_itinerary.address,
    image: copy_itinerary.image,
    vote: 0,
    rating: 0,
    }
  end

  def get_create_itinerary_detail(params)
    start_date = get_dates_array_full(params[:date])[0]
    end_date = get_dates_array_full(params[:date])[1]
    travel_days = get_travel_days(start_date, end_date)
    address = params[:address].downcase
    image = get_photo_address_all(address)
    {title: params[:title],
    start_date: start_date,
    end_date: end_date,
    travel_days: travel_days,
    address: address,
    image: image,
    vote: 0,
    rating: 0,
    }
  end

  def get_dates_array(start_date,end_date)
    date_array = (start_date..end_date).to_a
  end

  def get_dates_array_full(date_range)
    start_date_arr = date_range.split(' ')[0].split('-')
    end_date_arr = date_range.split(' ')[2].split('-')
    start_date = Date.new(start_date_arr[0].to_i,start_date_arr[1].to_i,start_date_arr[2].to_i)
    end_date = Date.new(end_date_arr[0].to_i,end_date_arr[1].to_i,end_date_arr[2].to_i)
    date_array = (start_date..end_date).to_a
    date_out = [start_date, end_date, date_array]
  end

  def get_travel_days(start_date,end_date)
    travel_days = (end_date - start_date).to_i + 1
  end

  def itinerary_params
    params.require(:itinerary).permit(:review, :recommend, :pros, :cons)
  end

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
