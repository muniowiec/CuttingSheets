Rails.application.routes.draw do
  resources :ordersheets
  resources :sheets
  resources :calculations
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'mainpage#index'
  get 'export' => 'export#index'
  get 'claim' => 'export#claim'
end
