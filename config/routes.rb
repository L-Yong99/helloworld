Rails.application.routes.draw do
  devise_for :users

  root to: "itineraries#home"

  resources :itineraries, only: [:index, :new, :create, :show, :destroy] do

    member do
      get :home
      get :plan
      post :plan, to: 'itineraries#save'
      post :delete, to: 'itineraries#delete'
      get :summary

    end

    collection do
      get :dashboard
      get :search
    end

    resources :activities, only: [:show]



  end

  resources :users, only: [:edit, :update]

end
