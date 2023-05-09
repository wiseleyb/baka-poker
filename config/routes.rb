Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  resources :games do
    collection do
      get :reset
    end
    member do
      get :check_call
      get :fold
      get :raise_pot
    end
  end

  # Defines the root path route ("/")
  root "games#index"
end
