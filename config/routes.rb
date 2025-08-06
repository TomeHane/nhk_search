Rails.application.routes.draw do
  get 'programs/index'
  root 'home#index'
  resources :programs, only: [:index]
end
