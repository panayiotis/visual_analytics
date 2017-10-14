Rails.application.routes.draw do
  devise_for :users
  get '/geojson/:dataset', to: 'geojson#show', constraints: { format: 'json' }
  get '/geojson/:dataset/:level', to: 'geojson#show', constraints: { format: 'json' }
  get '/geojson/:dataset/:level/:like', to: 'geojson#show', constraints: { format: 'json' }
  get 'components', to: 'components#index'
  get 'components/:action', to:  'components#:action'
  get 'description', to:  'static#description'
  get 'layout', to:  'static#layout'
  resources :datasets
  resources :reports
  root to: 'reports#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
