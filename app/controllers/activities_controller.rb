class ActivitiesController < ApplicationController
  def show
    @navbar = "none"
    @itinerary = Itinerary.find(params[:itinerary_id])
    start_date = @itinerary.start_date
    end_date = @itinerary.end_date
    date_arr = (start_date..end_date).to_a
    @dates = date_arr
    @days_count = date_arr.count
    @day = params[:id].to_i
    activities = Activity.where(itinerary: @itinerary, day: @day).order(:event_sequence)
    @activities_done = Activity.where(itinerary: @itinerary, day: @day, status: "updated").order(:event_sequence)
    @date_day = @dates[@day-1]
    if activities.count != 0
      lngAcc = 0
      latAcc = 0
      activities.each do |activity|
        lngAcc = lngAcc + activity.place.lng
        latAcc = latAcc + activity.place.lat
       end
      @center = [latAcc/activities.count, lngAcc/activities.count]
    else
      @center = [0, 0]
    end
    @activities = activities.map do |activity|
      {
        id: activity.id,
        day: activity.day,
        date: activity.date,
        place_id: activity.place_id,
        event_sequence: activity.event_sequence,
        status: activity.status,
        coordinates: [activity.place.lng,activity.place.lat],
        info_window: render_to_string(partial: "info_window_review", locals: {place: activity.place, itineraryId: @itinerary.id,activity: activity})
      }
    end
    @activities = @activities.to_json
    geodata = {type: "FeatureCollection"}
    features = activities.map do |activity|
      {
        type: "Feature",
        geometry: {
            type: "Point",
            coordinates: [activity.place.lng, activity.place.lat]
        },
        properties: {
            name: activity.place.name,
            description: activity.place.description,
            category: activity.place.category,
            rating: activity.place.rating,
            booking: activity.place.booking,
            lat: activity.place.lat,
            lng: activity.place.lng,
            image: activity.place.image,
            country: activity.place.country,
            review: activity.place.review_summary,
            placeId: activity.place.id,
            activityId: activity.id,
            defaultIcon: "default_icon",
            activeIcon: "active_icon",
            info_window: render_to_string(partial: "info_window_review", locals: {place: activity.place, itineraryId: @itinerary.id,activity: activity})
        },
      }
    end
    geodata[:features] = features
    @geodata_json = geodata.to_json
  end

  def create
    result = Cloudinary::Uploader.upload(params[:photo])
    activity = Activity.find((params[:data]))
    activity.update(status: "updated")
    activity.save
    review = Review.new(comment: params[:text], rating: params[:rating])
    review.photo.attach(params[:photo])
    review.user = current_user
    review.activity = activity
    if review.save
      redirect_to "/itineraries/#{params[:itinerary_id]}/activities/#{params[:id]}"
    end

    # @itinerary = Itinerary.find(params[:itinerary_id])
    # @place = Place.find(params[:place_id])

    # @activity = Activity.new(
    #   itinerary: @itinerary
    #   place: @place
    #   day: params[:day]
    #   data: params[:data]
    # )

    # @acitivity.save

    # respond_to do |format|
    #   # format.json { render json: { hello: 'world' } }
    #   format.json
    # end

  end



end
