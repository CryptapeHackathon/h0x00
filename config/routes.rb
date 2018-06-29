Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: "chains#index"
  resources :chains, only: [:index]
  resources :orders, only: [:new]
  resources :admins, only: [:index]
  get 'orders/sell', to: "orders#sell"
end
