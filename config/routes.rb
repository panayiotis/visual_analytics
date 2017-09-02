Rails.application.routes.draw do
  resources :datasets,only: [:index, :show]
  resources :reports,only: [:index, :show]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  #root to: 'static#landing'
  root to: 'datasets#index'
  get ':action' => 'static#:action'
  get '/p' => 'static#public_integrity'
  get '/geojson/:level', to: 'geojson#show', constraints: { format: 'json' }
  get '/geojson/:level/:like', to: 'geojson#show', constraints: { format: 'json' }
end
