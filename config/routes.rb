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
  scope :sales, section: :sales do
    resources :client_notes, path: :notes do
      get :show_lines, on: :member
      resources :note_lines, path: :lines
    end
  end
  scope :products, section: :products do
    resources :products
  end
  namespace :admin, section: :admin do
    resources :users, path: :users
    resources :vats, path: :vats
    resources :payment_types, path: :payment_types
    resources :suppliers, path: :suppliers
    resources :clients, path: :clients
    resources :product_types, path: :product_types
    resources :product_subtypes, path: :product_subtypes
    resources :products, path: :products
    resources :product_authors, path: :product_authors
  end
  match ':section/:controller(/:action(/:id))', via: [:get, :post, :put, :delete, :patch]

end
