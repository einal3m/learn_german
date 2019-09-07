Rails.application.routes.draw do
  root 'welcome#index'
  
  get  '/signup',  to: 'users#new'
  get '/profile/:id', as: 'profile', to: 'users#show'

  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'

  resources :users, only: [:create]
  resources :progress, only: [:index]
end
