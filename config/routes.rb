Uberzeit::Application.routes.draw do


  root :to => 'sessions#new'

  resources :time_sheets, only: [:show] do

    resources :recurring_entries, except: [:show, :index]
    resources :timers, only: [:show, :edit, :update, :destroy]

    member do
      get '/date/:date', to: 'time_sheets#show', as: :show_date
      put '/date/:date/stop-timer', to: 'time_sheets#stop_timer'

      get '/date/:date/summary', to: 'time_sheets#summary_for_date'
    end

    resources :absences do
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

  resources :public_holidays

  resources :users, except: [:destroy] do
    resources :employments

    namespace :summaries do
      namespace :work do
        get '/:year', to: 'my_work#year', as: :year
        get '/:year/:month', to: 'my_work#month', as: :month
      end
      namespace :absence do
        get '/:year', to: 'my_absence#year', as: :year
        get '/:year/:month', to: 'my_absence#month', as: :month
      end
    end

    collection do
      namespace :summaries do
        namespace :work do
          get '/:year(/team/:team_id)', to: 'work#year', as: :year
          get '/:year/:month(/team/:team_id)', to: 'work#month', as: :month
        end

        namespace :absence do
          get '/:year(/team/:team_id)', to: 'absence#year', as: :year
          get '/:year/:month(/team/:team_id)', to: 'absence#month', as: :month
        end

        namespace :vacation do
          get '/:year(/team/:team_id)', to: 'vacation#year', as: :year
          get '/:year/:month(/team/:team_id)', to: 'vacation#month', as: :month
        end
      end
    end
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
