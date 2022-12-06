class ListsController < ApplicationController
  before_action :set_itinerary, only: [:create, :delete, :check]

  def create
    content = params[:todo]
    new_list = List.new(content: content, status: "pending", itinerary: @itinerary)
    respond_to do |format|
      if new_list.save
        @todolist = List.where(itinerary: @itinerary)
        @todolist_count = @todolist.count
        format.json
      end
    end
  end

  def delete
    todo_data = params[:data].to_i
    mylist = List.find(todo_data)
    respond_to do |format|
      if mylist.destroy
        @todolist = List.where(itinerary: @itinerary)
        @todolist_count = @todolist.count
        format.json
      end
    end
  end

  def check
    todo_data = JSON.parse(params[:data])
    list = List.find(todo_data[0])
    todo_data[1] == true ? list.update(status: 'updated') : list.update(status: 'pending')
    respond_to do |format|
      if list.save
        format.json
      end
    end
  end

  private

  def set_itinerary
    @itinerary = Itinerary.find(params[:itinerary_id])
  end

end
