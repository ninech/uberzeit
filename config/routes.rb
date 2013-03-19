Uberzeit::Application.routes.draw do


  root :to => 'sessions#new'

  resources :time_sheets do
    #resources :single_entries, except: [:show, :index]
    resources :recurring_entries, except: [:show, :index]

    resources :recurring_entries, except: [:show, :index]
    resources :timers, only: [:show, :edit, :update]
    member do
      match '/days/:date', to: 'time_sheets#show', via: :get
      match '/stop-timer', to: 'time_sheets#stop_timer', via: :put
    end

    resources :absences, only: :index do
      collection do
        get '/year/:year', to: 'absences#index', as: 'year'
        resources :time_entries, controller: :absence_time_entries, as: :absence_time_entries, only: :create
      end
    end

    resources :time_entries, except: [:show, :index] do
      member do
        put 'exception_date/:date', action: 'exception_date', as: :exception_date
      end
    end
  end

  resources :users do
    member do
      get 'edit'
      put 'update'
    end
    collection do
      get 'index'
    end
    resources :employments
  end

  resources :time_types

  match '/auth/:provider/callback', to: 'sessions#create'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
