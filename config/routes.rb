Uberzeit::Application.routes.draw do

  year_month_team_id_constraints = {year: /\d+/, month: /\d+/, team_id: /\d+/}

  root :to => 'sessions#new'


  # session stuff
  resource :session, only: [:new, :create, :destroy]
  match '/auth/:provider/callback', to: 'sessions#create'
  match '/logout', to: 'sessions#destroy', as: 'logout'


  # users scope
  resources :users do
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
    get '/overview/users/:user_id', to: 'overview#index', as: :overview_user

    namespace :work do
      get '/users/:user_id/:year', to: 'my_work#year', as: :user_year
      get '/users/:user_id/:year/:month', to: 'my_work#month', as: :user_month

      get '/:year(/team/:team_id)', to: 'work#year', as: :year
      get '/:year/:month(/team/:team_id)', to: 'work#month', as: :month
    end

    namespace :absences do
      get '/:year(/team/:team_id)', to: 'absence#year', as: :year, constraints: year_month_team_id_constraints
      get '/:year/:month(/team/:team_id)', to: 'absence#month', as: :month, constraints: year_month_team_id_constraints
      get '/:year/:month(/team/:team_id)/as/calendar', to: 'absence#calendar', as: :calendar, constraints: year_month_team_id_constraints
    end

    namespace :vacation do
      get '/:year(/team/:team_id)', to: 'vacation#year', as: :year
      get '/:year/:month(/team/:team_id)', to: 'vacation#month', as: :month
    end

    namespace :activities do
      get '/billability(/:date)', to: 'billability#index', as: :billability
      get '/billing', to: 'billing#index', as: :billing
      get '/filter/:year/:month/:group_by', to: 'filter#index', as: :filter
      get '/detailed/:year/:month/(:customer_id)', to: 'detailed#index', as: :detailed
    end
  end

  resources :teams, except: :show

  # API
  mount API::User => '/api'
  mount API::App => '/api/app'
end
