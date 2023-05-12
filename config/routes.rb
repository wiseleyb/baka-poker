Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  resources :games do
    collection do
      get :reset
    end
    member do
      get :action_check
      get :action_fold
      get :action_bet
      get :action_call
      get :action_raise
      get :next_hand
    end
  end

  # Defines the root path route ("/")
  root "games#index"
end
