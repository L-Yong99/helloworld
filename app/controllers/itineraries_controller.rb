class ItinerariesController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!, only: [:index, :show, :home]
  before_action :set_itinerary, only: %i[review]

  def home
    @navbar = "home"
    @itineraries = Itinerary.order(vote: :desc).limit(6)
  end

  def index
    @navbar = "others"
    @itineraries = Itinerary.all
  end

  def show
    @navbar = "others"
    @itinerary = Itinerary.find(params[:id])
  end

  def new
    @navbar = "others"
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
      @activity.status = "pending"
      @activity.place = place
      @activity.itinerary = itinerary
      if place.booking == true
        @activity.booking = "pending"
      else
        @activity.booking = "none"
      end

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

  def update
    @itinerary = Itinerary.find(params[:id])

    unless params[:phase]
      @itinerary.update!(itinerary_params)
      redirect_to summary_itinerary_path(@itinerary)
    end

    case params[:phase]
    when "ongoing"
      @itinerary.update!(phase: params[:phase])
      redirect_to plan_itinerary_path(@itinerary)
    when "require review"
      @itinerary.update!(phase: params[:phase])
      redirect_to summary_itinerary_path(@itinerary)
    when "completed"
      @itinerary.update!(phase: params[:phase])
      redirect_to review_itinerary_path(@itinerary)
    end

    # @itinerary.update!(review: params[:review], recommend: params[:recommend], pros: params[:pros], cons: params[:cons])
    #   redirect_to summary_itinerary_path(@itinerary)
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
      # a.event_sequence = a.event_sequence - 1
      event_sequence = a.event_sequence - 1
      a.update(event_sequence:event_sequence)
      a.save
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

  def sort
    itinerary = Itinerary.find(params[:id])
    @itinerary_id = params[:id]
    activities = Activity.where(itinerary_id: @itinerary_id)
    @dates = (itinerary.start_date..itinerary.end_date).to_a
    sort_hash = json_to_hash(params[:data])
    p_from = sort_hash[:p_from]
    p_to = sort_hash[:p_to]
    e_from = sort_hash[:e_from]
    e_to = sort_hash[:e_to]

    ## Get the activity that was sorted
    activity_selected = activities.find_by(day:p_from,event_sequence:e_from )

    ## Reduce all event seqence from day by 1
    activity_from = activities.where(day:p_from).where('event_sequence > ?', e_from)
    activity_from.each do |a|
      event_sequence = a.event_sequence - 1
      a.update(event_sequence:event_sequence)
      a.save
    end

    ## increment all event sequence to day by 1
    activity_to = activities.where(day:p_to).where('event_sequence >= ?', e_to)
    activity_to.each do |a|
      event_sequence = a.event_sequence + 1
      a.update(event_sequence:event_sequence)
      a.save
    end

    ## Get acitivity that is sorted
    activity_selected.update(day: p_to, event_sequence:e_to,date: @dates[p_to - 1])
    activity_selected.save

    ## Get updated activites for the day
    @activities = Activity.where(itinerary_id: @itinerary_id)
    respond_to do |format|
     format.json # Follow the classic Rails flow and look for a create.json view
    end
  end

  def complete
  end

  def summary
    @navbar = "others"
    @itinerary = Itinerary.find(params[:id])
    start_date = @itinerary.start_date
    end_date = @itinerary.end_date
    date_arr = (start_date..end_date).to_a
    @dates_all = date_arr
    @dates = date_arr
    @activities = Activity.where(itinerary: @itinerary)
    @activities_completed = @activities.where(status: "updated").limit(5)

    ## Get bookings
    @total_require_bookings_count = @activities.joins(:place).where("places.booking = ? ", true).count
    @activities_with_booking = @activities.joins(:place).where("places.booking = ? ", true)
    @activities_with_booking_pending = Activity.where(booking: "pending")
# raise
  end

  def filter
    day = params[:date].to_i
    @itinerary = Itinerary.find(params[:id])
    start_date = @itinerary.start_date
    end_date = @itinerary.end_date
    date_arr = (start_date..end_date).to_a
    @dates_all = date_arr

    if day == 0
      @dates = date_arr
    else
      @dates = date_arr.slice(day-1,1)
    end
    @activities = Activity.where(itinerary: @itinerary)
    respond_to do |format|
      format.json # Follow the classic Rails flow and look for a create.json view
    end
# debugger
  end

  def dashboard
    @navbar = "others"
    @currentUser = current_user.id
    @myitineraries = Itinerary.where(user: current_user)
    @inplan = @myitineraries.where(phase: "in plan")
    @ongoing = @myitineraries.where(phase: "ongoing")
    @review = @myitineraries.where(phase: "require review")
    @completed = @myitineraries.where(phase: "completed")
    # raise
  end

  def search
  end

  def review
  end

  def bookingcheck
    booking_data = JSON.parse(params[:data])
    activity = Activity.find(booking_data[0])
    if booking_data[1] == true
      activity.update(booking: 'updated')
    else
      activity.update(booking: 'pending')
    end
    respond_to do |format|
      if activity.save
        format.json # Follow the classic Rails flow and look for a create.json view
      end
    end

    # debugger
  end


  private

  def itinerary_params
    params.require(:itinerary).permit(:review, :recommend, :pros, :cons)
  end

  def set_itinerary
    @itinerary = Itinerary.find(params[:id])
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
