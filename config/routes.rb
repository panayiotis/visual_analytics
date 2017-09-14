Rails.application.routes.draw do
  get 'components', to: 'components#index'
  get 'components/:action', to:  'components#:action'
  get 'layout', to:  'static#layout'
  resources :reports
  resources :datasets
  root to: 'static#welcome'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
