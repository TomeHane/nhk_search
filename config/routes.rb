Rails.application.routes.draw do
  root 'home#index'
  resources :programs, only: [:index]
end
