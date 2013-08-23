class API::User::Resources::Projects < Grape::API

  resource :projects do
    desc 'Lists all projects'
    params do
      requires :customer_id, type: Integer
    end
    get do
      present Project.by_customer(params[:customer_id]), with: API::User::Entities::Project
    end
  end

end
