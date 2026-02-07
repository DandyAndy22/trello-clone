Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  namespace :api do
    namespace :v1 do
      post '/signup', to: 'authentication#signup'
      post '/login', to: 'authentication#login'

      resources :boards, only: [:index, :create, :show, :destroy] do
        resources :lists, only: [:index, :create]
      end

      resources :lists, only: [:destroy] do
        resources :cards, only: [:index, :create, :update]
      end

      resources :cards, only: [:update]
    end
  end
end
