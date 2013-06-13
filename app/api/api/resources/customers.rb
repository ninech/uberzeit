class API::Resources::Customers < Grape::API

  resource :customers do
    desc 'Lists all customers'
    get do
      present Customer.all, with: API::Entities::Customer
    end

    namespace ':customer_id' do
      mount API::Resources::Projects
    end
  end

end
