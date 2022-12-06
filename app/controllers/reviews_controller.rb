class ReviewsController < ApplicationController
  def create
    activity = Activity.find((params[:data]))
    review = Review.new(comment: params[:text], rating: params[:rating], user: current_user, activity: activity)
    review.photo.attach(params[:photo]) unless params[:photo].nil?
    # result = Cloudinary::Uploader.upload(params[:photo]) # Note this is to see the result of the cloudinary upload(keep for reference)
    if review.save
      activity.update(status: "updated")
      redirect_to "/itineraries/#{params[:itinerary_id]}/activities/#{params[:id]}"
    end
  end

  def destroy
    review = Review.find(params[:id])
    activity = review.activity
    if review.destroy
      activity.reviews.count == 0 && activity.update(status: "pending")
      redirect_to "/itineraries/#{params[:itinerary_id]}/activities/#{params[:activity_id]}"
    end
  end
end
