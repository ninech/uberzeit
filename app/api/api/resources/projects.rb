class API::Resources::Projects < Grape::API

  resource :projects do
    desc 'Lists all projects'
    params do
      requires :customer_id, type: Integer
    end
    get do
      projects = [
        OpenStruct.new({name: 'Cluster One', id: 1, customer_id: 1}),
        OpenStruct.new({name: 'SuperDuper Cluster 77', id: 2, customer_id: 2}),
        OpenStruct.new({name: 'Manananana Service 34', id: 2, customer_id: 2})
      ]
      present projects.select {|project| project.customer_id == params[:customer_id]}, with: API::Entities::Project
    end
  end

end
