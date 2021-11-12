Rails.application.routes.draw do
  namespace :admin do
      resources :bots
      resources :pairs
      resources :balances
      resources :orders

      root to: "bots#index"
    end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
