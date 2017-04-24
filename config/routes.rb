Rails.application.routes.draw do

  resources :orders do
    member do
      get :purchase
      get :validate
      post :make_purchase
    end
  end

  resources :order_products do
    member do
      get :validate
      post :make_purchase
    end
  end

  resources :events
  resources :products
  resource :cart, only: [:show] do
    post "add", path: "add/:id"
    get :checkout
  end

  get "admin/:action", controller: 'admin', as: 'admin'
  get 'admin' => "admin#index"

  devise_for :users, controllers: {
    # For Recaptcha verification
    registrations: 'registrations', as: 'register',
    passwords:     'passwords', as: 'secret'
  },
  path: '', path_names: {
    confirmation:  'verification',
    unlock:        'unblock',
    sign_in:       'login',
    sign_out:      'logout',
    sign_up:       'sign_up'
  }

  resources :users
  resources :roles

  root 'home#index'
end
