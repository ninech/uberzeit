class API::User::Resources::Customers < Grape::API

  resource :customers do
    desc 'Lists all customers'
    get do
      present Customer.all, with: API::User::Entities::Customer
    end

    namespace ':customer_id' do
      mount API::User::Resources::Projects
    end
  end

end
