Rails.application.routes.draw do

  resources :orders do
    member do
      get :purchase
      get :validate
      post :make_purchase
    end
  end
  resources :events
  get "admin/:action", controller: 'admin', as: 'admin'
  get 'admin' => "admin#index"

  resources :roles
  resources :users
  devise_for :users, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    password: 'secret',
    confirmation: 'verification',
    unlock: 'unblock',
    registration: 'register',
    sign_up: 'sign_up' }

  root 'home#index'
end
