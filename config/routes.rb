Rails.application.routes.draw do
  devise_for :users

  root to: "itineraries#index"

  resources :itineraries, only: [:new, :create, :show, :destroy] do

    member do
      get :plan
      post :plan, to: 'itineraries#complete'
      get :summary
    end

    collection do
      get :dashboard
      get :search
    end

    resources :activities, only: [:show]

  end
end
