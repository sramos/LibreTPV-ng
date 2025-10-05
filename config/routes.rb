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
  #root to: 'albarans#index', seccion: "caja", controller: "albarans", action: "index"
  match ':section/:controller(/:action(/:id))', via: [:get, :post, :put, :delete, :patch]
  scope :sales, section: :sales do
    match 'notes', to: 'client_note#index', via: :get
  end
end
