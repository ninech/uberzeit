class API::User::Resources::Customers < Grape::API

  resource :customers do
    desc 'Lists all customers'
    params do
      optional :number, type: Integer, desc: 'Search for a specific customer by customer number'
    end
    get do
      customers = Customer
      if params[:number]
        customers = customers.where(number: params[:number])
      end
      present customers.all, with: API::User::Entities::Customer
    end

    namespace ':customer_id' do
      mount API::User::Resources::Projects
    end
  end

end
