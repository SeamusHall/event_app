Rails.application.routes.draw do
  require 'sidekiq/web'

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

  resources :categories, only: [:index,:show]
  resources :products, only: [:index,:show]
  resource :cart, only: [:show] do
    post "add", path: "add/:id"
    post "remove", path: "remove/:id"
    post "clear", path: "clear"
    post :auto_update_role
  end

  devise_for :users, controllers: {
    # For Recaptcha verification
    registrations: 'registrations',
    passwords:     'passwords'
  },
  path: '', path_names: {
    confirmation:  'verification',
    unlock:        'unlock',
    sign_in:       'login',
    sign_out:      'logout',
    sign_up:       'sign_up'
  }

  resources :users
  # routes for users account restore
  resources :restore, only: [:new, :create]

  # routes for admin interface
  get "admin" => "admin#index"
  namespace :admin do
    mount Sidekiq::Web => '/sidekiq'
    get "layouts/admin_navigation"    => "layouts#admin_navigation"
    get "layouts/show_user_info/:id"  => "layouts#show_user_info"
    get "orders/show_orders_valid"    => "orders#show_orders_valid"
    get "orders/show_orders_progress" => "orders#show_orders_progress"
    get "orders/show_orders_pending"  => "orders#show_orders_pending"
    get "orders/show_orders_canceled" => "orders#show_orders_canceled"
    get "orders/show_orders_declined" => "orders#show_orders_declined"
    get "orders/show_orders_refunded" => "orders#show_orders_refunded"
    resources :users
    resources :roles
    resources :categories
    resources :orders do
      member do
        get :validate
        get :update_stock_totals
      end
    end
    resources :events
    resources :order_products, except: [:index] do
      member do
        get :validate
        get :update_stock_totals
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

  # Doc Routes
  get "docs"                => "docs#index"
  get "class_list"          => "docs#class_list"
  get "method_list"         => "docs#method_list"
  get "file_list"           => "docs#file_list"
  get "readme"              => "docs#readme"
  get "class_structure"     => "docs#class_structure"
  get "top_level_namespace" => "docs#top_level_namespace"
  namespace :docs do
    # Helpers Routes
    get "helpers/application_helper"                  => "helpers#application_helper"

    # Modules Routes
    get "modules/admin"                               => "modules#admin"
    get "modules/action_cable"                        => "modules#action_cable"
    get "modules/events"                              => "modules#events"

    # Controller Routes
    get "controllers/admin_controller"                => "controllers#admin_controller"
    get "controllers/application"                     => "controllers#application"
    get "controllers/application_controller"          => "controllers#application_controller"
    get "controllers/carts_controller"                => "controllers#cart_controller"
    get "controllers/events_controller"               => "controllers#events_controller"
    get "controllers/home_controller"                 => "controllers#home_controller"
    get "controllers/layouts_controller"              => "controllers#layouts_controller"
    get "controllers/order_products_controller"       => "controllers#order_products_controller"
    get "controllers/orders_controller"               => "controllers#orders_controller"
    get "controllers/passwords_controller"            => "controllers#passwords_controller"
    get "controllers/products_controller"             => "controllers#products_controller"
    get "controllers/registrations_controller"        => "controllers#registrations_controller"
    get "controllers/restore_controller"              => "controllers#restore_controller"
    get "controllers/users_controller"                => "controllers#users_controller"

    namespace :admin do
      get "controllers/attachment_controller"         => "controllers#attachment_controller"
      get "controllers/categories_controller"         => "controllers#categories_controller"
      get "controllers/events_controller"             => "controllers#events_controller"
      get "controllers/layouts_controller"            => "controllers#layouts_controller"
      get "controllers/order_products_controller"     => "controllers#order_products_controller"
      get "controllers/orders_controller"             => "controllers#orders_controller"
      get "controllers/products_controller"           => "controllers#products_controller"
      get "controllers/roles_controller"              => "controllers#roles_controller"
      get "controllers/users_controller"              => "controllers#users_controller"
    end

    # Models Routes
    get "models/ability"                              => "models#ability"
    get "models/application_record"                   => "models#application_record"
    get "models/cart"                                 => "models#cart"
    get "models/cart_item"                            => "models#cart_item"
    get "models/category"                             => "models#category"
    get "models/ckeditor_asset"                       => "models#ckeditor_asset"
    get "models/ckeditor_attachment_file"             => "models#ckeditor_attachment_file"
    get "models/ckeditor_picture"                     => "models#ckeditor_picture"
    get "models/event"                                => "models#event"
    get "models/event_item"                           => "models#event_item"
    get "models/order"                                => "models#order"
    get "models/order_product"                        => "models#order_product"
    get "models/order_product_item"                   => "models#order_product_item"
    get "models/product"                              => "models#product"
    get "models/role"                                 => "models#role"
    get "models/user"                                 => "models#user"
    get "models/user_role"                            => "models#user_role"

    # Jobs Routes
    get "jobs/application_job"                        => "jobs#application_job"

    # Mailer Routes
    get "mailers/application_mailer"                  => "mailers#application_mailer"
    get "mailers/order_mailer"                        => "mailers#order_mailer"
    get "mailers/order_product_mailer"                => "mailers#order_product_mailer"

    # Libs Routes
    get "libs/application_responder"                  => "libs#application_responder"

    # Uploaders Routes
    get "uploaders/attachment_uploader"               => "uploaders#attachment_uploader"
    get "uploaders/ckeditor_attachment_file_uploader" => "uploaders#ckeditor_attachment_file_uploader"
    get "uploaders/ckeditor_picture_uploader"         => "uploaders#ckeditor_picture_uploader"

    # Workers Routes
    get "workers/product_worker"                      => "workers#product_worker"
    get "workers/thumbnail_worker"                    => "workers#thumbnail_worker"

    # Tests Routes
    get "tests/event_test"                            => "tests#event_test"
    get "tests/events_controller_test"                => "tests#events_controller_test"
    get "tests/home_controller_test"                  => "tests#home_controller_test"
    get "tests/role_test"                             => "tests#role_test"
    get "tests/roles_controller_test"                 => "tests#roles_controller_test"
    get "tests/user_test"                             => "tests#user_test"
  end

  root 'home#index'
end
