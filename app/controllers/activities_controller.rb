class ActivitiesController < ApplicationController
  before_action :set_itinerary, only: [:show, :save, :delete, :sort, :filter]
  before_action :set_date, only: [:show, :delete, :sort, :filter, :save]

  #  itinerary_activity GET    /itineraries/:itinerary_id/activities/:id(.:format) activities#show
  def show
    @navbar = "none"
    @day = params[:id].to_i
    activities = Activity.where(itinerary: @itinerary, day: @day).order(:event_sequence)
    @activities_done = Activity.where(itinerary: @itinerary, day: @day, status: "updated").order(:event_sequence)
    @date_day = @dates[@day-1]
    @center = get_markers_center(activities)
    @activities = map_activities(activities, @itinerary).to_json
    @geodata_json = get_geojson(activities).to_json
  end

  # AJAX - Activity create
  def save
    activity = new_activity(params)
    respond_to do |format|
      if activity.save
        @activities = Activity.where(itinerary: @itinerary)
        format.json
      else
        format.html { render plan_itinerary_path(@itinerary), status: :unprocessable_entity }
      end
    end
  end

  # AJAX - Activity delete
  def delete
    @activities = Activity.where(itinerary: @itinerary)
    activity = reduce_event_sequence(params, @itinerary)
    respond_to do |format|
      if activity.destroy
        format.json
      else
        format.html { render plan_itinerary_path(@itinerary), status: :unprocessable_entity }
      end
    end
  end

  # AJAX - Activity sort
  def sort
    @activities = sort_activities(params, @itinerary)
    respond_to do |format|
     format.json # Follow the classic Rails flow and look for a create.json view
    end
  end

  # AJAX - Activity filter @ show/summary page
  def filter
    day = params[:date].to_i
    day == 0 ? @dates : @dates = @dates.slice(day-1,1)
    @activities = Activity.where(itinerary: @itinerary)
    respond_to do |format|
      format.json
    end
  end

  private

  def set_date
    itinerary = Itinerary.find(params[:itinerary_id])
    @dates = itinerary.get_dates_array(params[:itinerary_id])
  end

  def set_itinerary
    @itinerary = Itinerary.find(params[:itinerary_id])
  end

  def get_geojson(activities)
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
    return geodata
  end

  def map_activities(activities, itinerary)
    activities_map = activities.map do |activity|
      {
        id: activity.id,
        day: activity.day,
        date: activity.date,
        place_id: activity.place_id,
        event_sequence: activity.event_sequence,
        status: activity.status,
        coordinates: [activity.place.lng,activity.place.lat],
        info_window: render_to_string(partial: "info_window_review", locals: {place: activity.place, itineraryId: itinerary.id,activity: activity})
      }
    end
  end

  def get_markers_center(activities)
    if activities.count != 0
      lngAcc = 0
      latAcc = 0
      activities.each do |activity|
        lngAcc = lngAcc + activity.place.lng
        latAcc = latAcc + activity.place.lat
      end
      center = [latAcc/activities.count, lngAcc/activities.count]
    else
      center = [0, 0]
    end
  end

  def sort_activities(params, itinerary)
    activities = Activity.where(itinerary: itinerary)
    sort_hash = json_to_hash(params[:data])
    p_from = sort_hash[:p_from]
    p_to = sort_hash[:p_to]
    e_from = sort_hash[:e_from]
    e_to = sort_hash[:e_to]

    ## Get the activity that was sorted
    activity_selected = activities.find_by(day:p_from,event_sequence:e_from )

    ## Reduce all event seqence from day by 1
    activity_from = activities.where(day:p_from).where('event_sequence > ?', e_from)
    activity_from.each { |a| a.update(event_sequence: a.event_sequence - 1) }

    ## increment all event sequence to day by 1
    activity_to = activities.where(day:p_to).where('event_sequence >= ?', e_to)
    activity_to.each { |a| a.update(event_sequence: a.event_sequence + 1) }

    ## Get acitivity that is sorted
    activity_selected.update(day: p_to, event_sequence:e_to,date: @dates[p_to - 1])

    ## Get updated activites for the day
    activities = Activity.where(itinerary: @itinerary)
  end

  def reduce_event_sequence(params, itinerary)
    activity_id = params[:data].to_i
    activity = Activity.find(activity_id)
    activities_a = Activity.where(itinerary: itinerary, day: activity.day).where('event_sequence > ?', activity.event_sequence)
    activities_a.each {|activity| activity.update(event_sequence: activity.event_sequence - 1)}
    return activity
  end

  def new_activity(params)
    data_hash = JSON.parse(params[:data]).deep_symbolize_keys
    activities_count = Activity.where(day: data_hash[:day].to_i, itinerary: @itinerary).count
    data_hash[:event_sequence] = activities_count + 1
    place = Place.find(data_hash[:place_id])
    place.booking == true ? booking = "pending" : booking = "none"
    activity = Activity.new(date: data_hash[:date], day: data_hash[:day].to_i, event_sequence: data_hash[:event_sequence], status: "pending", place_id: data_hash[:place_id].to_i, itinerary: @itinerary, booking: booking)
  end

  def json_to_hash(json_data)
    data_hash = JSON.parse(json_data).deep_symbolize_keys
  end
end
