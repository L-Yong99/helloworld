Rails.application.routes.draw do
  get 'lists/create'
  get 'lists/destroy'
  get 'lists/check'
  get 'reviews/create'
  get 'reviews/delete'
  devise_for :users

  root to: "itineraries#home"

  resources :itineraries do

    member do
      get :home
      get :plan
      # post :plan, to: 'itineraries#save'
      # post :delete, to: 'itineraries#delete'
      # post :sort, to: 'itineraries#sort'
      get :summary
      # post :summary, to: 'itineraries#filter'
      post :bookingcheck, to: 'itineraries#bookingcheck'
      # post :addlist, to: 'itineraries#addlist'
      # post :addlistcheck, to: 'itineraries#addlistcheck'
      # post :listdelete, to: 'itineraries#listdelete'
      post :addimage, to: 'itineraries#addimage'
      get :gallery, to: 'itineraries#gallery'
      get :review
    end

    collection do
      get :dashboard
      get :search
    end

    resources :activities, only: [:show, :create, :update] do

      resources :reviews, only: [:create, :destroy]

      collection do
        post :plan, to: 'activities#save'
        post :delete, to: 'activities#delete'
        post :sort, to: 'activities#sort'
        post :summary, to: 'activities#filter'
      end
    end

    resources :lists, only: [:create] do
      collection do
        post :check, to: 'lists#check'
        post :delete, to: 'lists#delete'
      end

    end

  end

  resources :users, only: [:edit, :update]

  # post 'new_activity/:itinerary_id/:place_id', to: 'activities#create', as: :new_activity

end
