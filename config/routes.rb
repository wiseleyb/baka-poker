Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  resources :games do
    collection do
      get :reset
      post :reset
    end
    member do
      post :player_action
      post :next_hand
    end
  end

  # Defines the root path route ("/")
  root "games#index"
end
