Rails.application.routes.draw do
  root "pages#index"

  # Pages
  get "home" => "pages#home", as: :home
  get "terms-of-service" => "pages#terms_of_service"
  get "privacy-policy" => "pages#privacy_policy"
  get "contact" => "pages#contact"
  get "sitemap" => "pages#sitemap"
  resources :pages, except: [ :index, :show ], param: :aid do
    # Questions
    resources :questions, only: [ :index, :create, :update, :destroy ], param: :aid
  end

  # Blocks
  resources :blocks, except: [ :index, :show ], param: :aid do
    member do
      patch :up
      patch :down
    end
  end

  # Accounts
  get "/@:name_id" => "accounts#show", as: :account
  get "/@:name_id/:page_name_id" => "accounts#page", as: :account_page
  resources :accounts, only: [ :index ], param: :aid

  # Images
  resources :images, param: :aid do
    member do
      post "create_variant" => "images#create_variant", as: :create_variant
      delete "delete_variant" => "images#delete_variant", as: :delete_variant
      delete "delete_original" => "images#delete_original", as: :delete_original
    end
  end

  # Documents
  resources :documents, except: [ :show ], param: :aid
  resources :documents, only: [ :show ], param: :name_id

  # Sessions
  get "sessions/start"
  delete "signout" => "sessions#signout"
  resources :sessions, except: [ :new, :create ], param: :aid

  # Signup
  get "signup" => "signup#new"
  post "signup" => "signup#create"

  # OAuth
  post "oauth/start" => "oauth#start"
  get "oauth/callback" => "oauth#callback"
  post "oauth/fetch" => "oauth#fetch"

  # Settings
  get "settings" => "settings#index"
  get "settings/account" => "settings#account"
  patch "settings/account" => "settings#patch_account"
  get "settings/leave" => "settings#leave"
  delete "settings/leave" => "settings#delete_leave"

  # Others
  get "up" => "rails/health#show", as: :rails_health_check

  # Errors
  match "*path", to: "application#routing_error", via: :all
end
