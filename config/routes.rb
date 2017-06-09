Rails.application.routes.draw do
  require 'sidekiq/web'

  mount Sidekiq::Web => '/sidekiq'
  mount Ckeditor::Engine => '/ckeditor'
  resources :orders, except: [:destroy] do
    member do
      get :purchase
      post :make_purchase
      post :cancel
    end
  end

  resources :order_products, except: [:destroy, :index] do
    member do
      get :purchase
      post :make_purchase
      post :cancel
    end
  end

  get "layouts/terms"
  get "layouts/risk"
  get "layouts/instructions"

  resources :events, only: [:index,:show] do
    post :auto_update_role
  end
  resources :products, only: [:index,:show]
  resource :cart, only: [:show] do
    post "add", path: "add/:id"
    post "remove", path: "remove/:id"
    post "clear", path: "clear"
    post :auto_update_role
  end

  devise_for :users, controllers: {
    # For Recaptcha verification
    registrations: 'registrations', as: 'register',
    passwords:     'passwords', as: 'secret'
  },
  path: '', path_names: {
    confirmation:  'verification',
    unlock:        'unlock',
    sign_in:       'login',
    sign_out:      'logout',
    sign_up:       'sign_up'
  }

  resources :users

  # routes for admin interface
  get "admin" => "admin#index"
  namespace :admin do
    get "orders/show_orders_valid"    => "orders#show_orders_valid"
    get "orders/show_orders_progress" => "orders#show_orders_progress"
    get "orders/show_orders_pending"  => "orders#show_orders_pending"
    get "orders/show_orders_canceled" => "orders#show_orders_canceled"
    get "orders/show_orders_declined" => "orders#show_orders_declined"
    get "orders/show_orders_refunded" => "orders#show_orders_refunded"
    resources :users
    resources :roles
    resources :orders do
      member do
        get :validate
        get :send_email_and_update_totals
      end
    end
    resources :events
    resources :order_products, except: [:index] do
      member do
        get :validate
        get :send_email_and_update_totals
      end
    end
    resources :products do
      member do
        post :publish
        post :unpublish
      end
      resources :attachments, :only => [:create,:destroy]
    end
  end

  root 'home#index'
end
