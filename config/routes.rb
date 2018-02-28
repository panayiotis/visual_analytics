# For details on the DSL available within this file,
# see http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  root to: 'notebooks#index'

  devise_for :users
  resources :chunks, only: %i[index show], param: :key
  resources :geojson, only: %i[index show]
  resources :notebooks

end
