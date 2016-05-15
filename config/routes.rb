Rails.application.routes.draw do
  devise_for :admins, controllers: { registrations: 'manager/admin_registrations' }
  devise_for :users
  # devise_scope :users do
  #   post 'users/forgot_password' => 'devise/unlocks#create', :as => :user_forgot_password
  # end
  get 'manager' => 'manager/dashboard#index'
  namespace :manager do
    resources :networks
    resources :zones
    resources :clients
    resources :documents
    #resources :destinations, :only => [:index, :edit, :update, :create, :destroy]
    resources :destinations, :except => [:show]
    resources :rate_quote_options, :except => [:show]
    resources :rate_masters
    resources :rate_quotes, :only => [:index] 
    resources :rate_search, :except => [:show, :update, :destroy]
    resources :dashboard, :only => [:index]
    resources :rate_query_logs, :only => [:index]
    resources :admins, :only => [:index,:delete]
  end
  get ':controller(/:action(/:id))', controller: /manager\/[^\/]+/
  delete ':controller(/:action(/:id))', controller: /manager\/[^\/]+/
  post ':controller(/:action(/:id))', controller: /manager\/[^\/]+/
  get ':controller(/:action(/:id))'
  delete ':controller(/:action(/:id))'
  post ':controller(/:action(/:id))'
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'search#index'
  #get 'users#index', as: :user_root
  #admin_root 'manager/dashboard#index'
  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
