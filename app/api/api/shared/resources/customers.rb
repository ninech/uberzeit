class API::Shared::Resources::Customers < Grape::API

  resource :customers do
    desc 'Lists all customers'
    get do
      present Customer.all, with: API::Shared::Entities::Customer
    end

    namespace ':customer_id' do
      mount API::Shared::Resources::Projects
    end
  end

end
