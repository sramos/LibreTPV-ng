Rails.application.routes.draw do
  get "public/index"
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  #root 'home#index'

  root to: 'home#index', section: "inicio", controller: "home", action: "index"

  #
  # SALES SECTION
  #
  namespace :sales, section: :sales do
    #resources :client_notes, path: :notes do
    #  get :show_lines, on: :member
    #  resources :note_lines, path: :lines
    #end
    resources :client_notes, path: :notes do
      collection { post :filter }
      resources :note_lines, path: :note_lines, only: [:index, :edit, :update, :destroy] do
        collection do
          post :create_by_concept
          post :create_by_code
          post :create_by_name
        end
      end
      resources :client_invoices, path: :invoices, only: [:new, :create]
    end
    resources :client_invoices, path: :invoices, except: [:new, :create] do
      collection { post :filter }
    end
    resources :clients, path: :clients do
      collection { post :filter }
      member do
        get :add_credit
        get :invoice_products
      end
    end
    resources :cash, path: :cash, only: [:index, :new, :create]

    get 'products/search_by_code', to: 'products#search_by_code'
    get 'products/search_by_name', to: 'products#search_by_name'
  end
  #
  # PRODUCTS SECTION
  #
  namespace :products, section: :products do
    resources :products, path: :products do
      collection do
        post :filter
        post :search_by_code
        post :search_by_name
        get :product_subtypes
      end
      member do
        get :purchases
        get :sales
      end
    end
    resources :suppliers, path: :suppliers do
      collection { post :filter }
    end
  end
  #
  # ADMIN SECTION
  #
  namespace :admin, section: :admin do
    resources :authors, path: :authors do
      collection { post :filter }
      member { get :products }
    end
    resources :configs, path: :configs, only: [:index, :edit, :update]
    resources :publishers, path: :publishers do
      collection { post :filter }
    end
    resources :payment_types, path: :payment_types
    resources :product_types, path: :product_types do
      resources :product_subtypes, path: :product_subtypes
    end
    resources :users, path: :users
    resources :vats, path: :vats
  end
  #match ':section/:controller(/:action(/:id))', via: [:get, :post, :put, :delete, :patch]
end
