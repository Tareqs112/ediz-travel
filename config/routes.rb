Rails.application.routes.draw do
  resource :session, path: 'admin/session', only: [:new, :create, :destroy]
  get "up" => "rails/health#show", as: :rails_health_check

  # Admin Architecture (outside locale scope)
  get "sitemap.xml", to: "sitemaps#index", format: :xml, as: :sitemap

  namespace :admin do
    root to: "dashboard#index"
    get "operations", to: "operations#index", as: :operations
    get "operations/availability", to: "operations#availability", as: :operations_availability
    resources :tours, param: :slug
    resources :destinations, param: :slug
    resources :accommodations, param: :slug
    resources :packages, param: :slug
    resources :travel_guides, param: :slug do
      member do
        get :preview
        patch :publish
        patch :unpublish
        delete "body_images/:image_id", to: "travel_guides#remove_body_image", as: :remove_body_image
      end
      collection do
        post :upload_image
      end
    end
    resources :booking_requests, only: [:index, :show, :update] do
      post :convert_to_booking, on: :member
    end
    resources :trip_inquiries, only: [:index, :show, :update] do
      post :convert_to_booking, on: :member
    end
    resources :contact_messages, only: [:index, :show]
    resources :drivers do
      get "operations", to: "driver_operations#show", on: :member
    end
    resources :vehicles do
      get "operations", to: "vehicle_operations#show", on: :member
    end
    resources :commercial_vehicles
    resources :customers
    resources :bookings do
      resources :trip_services, except: [:index, :show]
    end
    resource :business_setting, only: [:edit, :update]
  end

  # Multilingual Public Routes
  scope "(:locale)", locale: /en|ar|tr|[a-z]{2}/ do
    # Navigation & Generic Inquiries
    get "plan-your-trip", to: "trip_inquiries#new", as: :plan_your_trip
    resources :trip_inquiries, only: [:create, :show]

    # Services Architecture
    get "services", to: "services#index", as: :services
    get "services/airport-transfer", to: "services#airport_transfer", as: :airport_transfer
    get "services/car-rental", to: "services#car_rental", as: :car_rental
    get "services/chauffeured-car", to: "services#chauffeured_car", as: :chauffeured_car
    get "services/private-tours", to: "services#private_tours", as: :private_tours
    
    # Aliased services (pointing to their respective controllers)
    resources :packages, path: "services/travel-packages", only: [:index, :show], param: :slug, as: :packages
    resources :accommodations, path: "services/accommodation", only: [:index, :show], param: :slug, as: :accommodations

    # Travel Guide
    resources :travel_guides, path: "travel-guide", only: [:index, :show], param: :slug

    # Other Primary Routes
    resources :tours, only: [:index, :show], param: :slug do
      resources :booking_requests, only: [:new, :create, :show]
    end

    get "about", to: "pages#about", as: :about
    get "contact", to: "pages#contact", as: :contact
    resources :contact_messages, only: [:create]
    get "faq", to: "pages#faq", as: :faq
    get "search", to: "search#index", as: :search

    root "pages#home"
  end
end
