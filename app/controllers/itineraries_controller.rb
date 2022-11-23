class ItinerariesController < ApplicationController
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
    itinerary = Itinerary.new(start_date:start_date,end_date:end_date,country:address,travel_days:travel_days)
    itinerary.user = current_user
    itinerary.save
  end

  def show
  end

  def destroy
  end

  def plan
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
