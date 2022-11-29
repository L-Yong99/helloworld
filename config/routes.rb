Rails.application.routes.draw do
  devise_for :users

  root to: "itineraries#home"

  resources :itineraries do

    member do
      get :home
      get :plan
      post :plan, to: 'itineraries#save'
      post :delete, to: 'itineraries#delete'
      post :sort, to: 'itineraries#sort'
      get :summary

    end

    collection do
      get :dashboard
      get :search
    end

    resources :activities, only: [:show, :create, :update]



  end

  resources :users, only: [:edit, :update]

end
