# For details on the DSL available within this file,
# see http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  root to: 'notebooks#index'

  devise_for :users
  resources :chunks, only: %i[index show], param: :key
  resources :notebooks
  get '/geojson/:dataset', to: 'geojson#show', constraints: { format: 'json' }
  get '/geojson/:dataset/:level', to: 'geojson#show', constraints: { format: 'json' }
  get '/geojson/:dataset/:level/:like', to: 'geojson#show', constraints: { format: 'json' }
end
