class API::Resources::Customers < Grape::API

  resource :customers do
    desc 'Lists all customers'
    get do
      customers = [
        OpenStruct.new({name: 'Blubb AG', id: 1}),
        OpenStruct.new({name: 'Yolo Inc.', id: 2})
      ]
      present customers, with: API::Entities::Customer
    end

    namespace ':customer_id' do
      mount API::Resources::Projects
    end
  end

end
