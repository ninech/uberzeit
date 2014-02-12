Uberzeit::Application.routes.draw do

  year_month_team_id_constraints = {year: /\d+/, month: /\d+/, team_id: /\d+/}

  root :to => 'sessions#new'


  # session stuff
  resource :session, only: [:new, :create, :destroy] do
    put '/language', action: :change_language
  end

  match '/auth/:provider/callback', to: 'sessions#create'
  match '/auth/failure', to: 'sessions#failure'
  match '/logout', to: 'sessions#destroy', as: 'logout'


  # users scope
  resources :users do
    member do
      put '/activate', to: 'users#activate', as: 'activate'
      put '/deactivate', to: 'users#deactivate', as: 'deactivate'
    end
    resource :password, only: [:edit, :update]

    resources :recurring_entries, except: [:show, :index]

    resources :absences do
      collection do
        get '/year/:year', to: 'absences#index', as: 'year'
        resources :time_entries, controller: :absence_time_entries, as: :absence_time_entries, only: :create
      end
    end

    get '/comparison/date/:date', to: 'comparison#show', as: :comparison

    resources :time_entries, except: [:show] do
      collection do
        get '/date/:date', to: 'time_entries#index', as: :show_date
        put '/date/:date/stop-timer', to: 'time_entries#stop_timer'

        get '/date/:date/summary', to: 'time_entries#summary_for_date'
      end
    end

    resources :employments
    resources :activities do
      collection do
        get '/date/:date', to: 'activities#index', as: :show_date
      end
    end

    resources :roles, only: [:index, :new, :create, :destroy]
  end

  # management
  resources :public_holidays, except: [:show]
  resources :time_types, except: [:show]
  resources :adjustments, except: [:show]
  resources :projects, except: [:show]
  resources :activity_types, except: [:show]


  # reporting
  namespace :reports do
    get '/overview/users/:user_id', to: 'overview#index', as: :overview
    get '/work/users/:user_id', to: 'my_work#show', as: :my_work
    get '/work', to: 'work#show', as: :work
    get '/absences', to: 'absence#show'
    get '/absences-calendar', to: 'absence#calendar', as: :absences_calendar
    get '/vacation', to: 'vacation#show'

    namespace :activities do
      get '/billability(/:date)', to: 'billability#index', as: :billability
      get '/billing', to: 'billing#index', as: :billing
      get '/filter', to: 'filter#index', as: :filter
      get '/detailed', to: 'detailed#index', as: :detailed
    end
  end

  resources :teams, except: :show

  resources :customers, except: :show

  # API
  mount API::User => '/api'
  mount API::App => '/api/app'
end
